From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] samples/bpf: Add tunnel set/get tests.
Date: Thu, 18 Aug 2016 21:10:05 -0700 (PDT)
Message-ID: <20160818.211005.1542807415356478774.davem@davemloft.net>
References: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbcHSEKG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 00:10:06 -0400
In-Reply-To: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Tue, 16 Aug 2016 07:03:01 -0700

> The patch creates sample code exercising bpf_skb_{set,get}_tunnel_key,
> and bpf_skb_{set,get}_tunnel_opt for GRE, VXLAN, and GENEVE.  A native
> tunnel device is created in a namespace to interact with a lwtunnel
> device out of the namespace, with metadata enabled.  The bpf_skb_set_*
> program is attached to tc egress and bpf_skb_get_* is attached to egress
> qdisc.  A ping between two tunnels is used to verify correctness and
> the result of bpf_skb_get_* printed by bpf_trace_printk.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Please respin, this doesn't apply cleanly to net-next.
