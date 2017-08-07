From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/15] net: sched: summer cleanup part 2,
 ndo_setup_tc
Date: Sun, 06 Aug 2017 21:37:49 -0700 (PDT)
Message-ID: <20170806.213749.505593800109957053.davem@davemloft.net>
References: <20170805145337.17728-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbdHGEhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:37:51 -0400
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat,  5 Aug 2017 16:53:22 +0200

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

Series applied, thanks Jiri.
