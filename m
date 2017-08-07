From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 00/16] net: sched: summer cleanup part 2,
 ndo_setup_tc
Date: Mon, 07 Aug 2017 09:43:44 -0700 (PDT)
Message-ID: <20170807.094344.1220382628179779025.davem@davemloft.net>
References: <20170807081532.32760-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59892 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751864AbdHGQns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 12:43:48 -0400
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  7 Aug 2017 10:15:16 +0200

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
> v1->v2:
> - added forgotten hns3pf bits

Series applied, thanks.
