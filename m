From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/5] net: sched: let the offloader decide what
 to offload
Date: Fri, 11 Aug 2017 13:47:17 -0700 (PDT)
Message-ID: <20170811.134717.2266880872443736719.davem@davemloft.net>
References: <20170809123035.7663-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, oss-drivers@netronome.com,
        ganeshgr@chelsio.com, jeffrey.t.kirsher@intel.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdHKUrT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:47:19 -0400
In-Reply-To: <20170809123035.7663-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  9 Aug 2017 14:30:30 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Currently there is a Qdisc_class_ops->tcf_cl_offload callback
> that is called to find out if cls would offload rule or not.
> This is only supported by sch_ingress and sch_clsact.
> So the Qdisc are to decide. However, the driver knows what is he
> able to offload, so move the decision making to drivers completely.
> Just pass classid there and provide set of helpers to allow
> identification of qdisc.
> 
> As a side effect, this actually allows clsact egress rules
> offload in mlxsw.

Series applied, thanks.
