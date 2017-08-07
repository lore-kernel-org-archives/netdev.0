From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/15] net: sched: summer cleanup part 2,
 ndo_setup_tc
Date: Mon, 7 Aug 2017 07:27:34 +0200
Message-ID: <20170807052734.GA2085@nanopsycho.orion>
References: <20170805145337.17728-1-jiri@resnulli.us>
 <20170806.213749.505593800109957053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35127 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751424AbdHGF1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 01:27:37 -0400
Received: by mail-wr0-f194.google.com with SMTP id c24so6873671wra.2
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 22:27:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170806.213749.505593800109957053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 07, 2017 at 06:37:49AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sat,  5 Aug 2017 16:53:22 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This patchset focuses on ndo_setup_tc and its args.
>> Currently there are couple of things that do not make much sense.
>> The type is passed in struct tc_to_netdev, but as it is always
>> required, should be arg of the ndo. Other things are passed as args
>> but they are only relevant for cls offloads and not mqprio. Therefore,
>> they should be pushed to struct. As the tc_to_netdev struct in the end
>> is just a container of single pointer, we get rid of it and pass the
>> struct according to type. So in the end, we have:
>> ndo_setup_tc(dev, type, type_data_struct)
>> 
>> There are couple of cosmetics done on the way to make things smooth.
>> Also, reported error is consolidated to eopnotsupp in case the
>> asked offload is not supported.
>
>Series applied, thanks Jiri.

Pushed this already? I just got an email from kbuildbot, I missed hns3pf
driver (3 days). I can send the fix as followup as well. Up to you.
