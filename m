From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/4] Add support for offloading
 packet-sampling
Date: Tue, 24 Jan 2017 13:44:53 -0500 (EST)
Message-ID: <20170124.134453.806828323728185014.davem@davemloft.net>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAXSo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 13:44:56 -0500
In-Reply-To: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 23 Jan 2017 11:07:07 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Yotam says:
> 
> The first patch introduces the psample module, a netlink channel dedicated
> to packet sampling implemented using generic netlink. This module provides
> a generic way for kernel modules to sample packets, while not being tied
> to any specific subsystem like NFLOG.
> 
> The second patch adds the sample tc action, which uses psample to randomly
> sample packets that match a classifier. The user can configure the psample
> group number, the sampling rate and the packet's truncation (to save
> kernel-user traffic).
> 
> The last two patches add the support for offloading the matchall-sample
> tc command in the mlxsw driver, for ingress qdiscs.
> 
> An example for psample usage can be found in the libpsample project at:
> https://github.com/Mellanox/libpsample

Series applied, thank you.
