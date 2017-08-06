From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 00/15] net: sched: summer cleanup part 2,
 ndo_setup_tc
Date: Sun, 6 Aug 2017 08:28:06 -0400
Message-ID: <d213c57b-76e3-0132-5ca9-7237c6e40280@mojatatu.com>
References: <20170805145337.17728-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37645 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdHFM2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 08:28:09 -0400
Received: by mail-io0-f194.google.com with SMTP id c74so3779843iod.4
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 05:28:09 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-05 10:53 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset focuses on ndo_setup_tc and its args.
> Currently there are couple of things that do not make much sense.
> The type is passed in struct tc_to_netdev, but as it is always
> required, should be arg of the ndo. Other things are passed as args
> but they are only relevant for cls offloads and not mqprio. Therefore,
> they should be pushed to struct. As the tc_to_netdev struct in the end
> is just a container of single pointer, we get rid of it and pass the
> struct according to type. So in the end, we have:
> ndo_setup_tc(dev, type, type_data_struct)
> 
> There are couple of cosmetics done on the way to make things smooth.
> Also, reported error is consolidated to eopnotsupp in case the
> asked offload is not supported.
> 

I did a quick review of all the patches and they are simple, nice
cleanups. Instead of acking each one individually, i am just acking
this one.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
