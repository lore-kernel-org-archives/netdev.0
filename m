From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2,net-next] samples/bpf: Add tunnel set/get tests.
Date: Fri, 19 Aug 2016 22:43:21 -0700 (PDT)
Message-ID: <20160819.224321.216830178281905910.davem@davemloft.net>
References: <1471632944-2315-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57179 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbcHTFnW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 01:43:22 -0400
In-Reply-To: <1471632944-2315-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Fri, 19 Aug 2016 11:55:44 -0700

> The patch creates sample code exercising bpf_skb_{set,get}_tunnel_key,
> and bpf_skb_{set,get}_tunnel_opt for GRE, VXLAN, and GENEVE.  A native
> tunnel device is created in a namespace to interact with a lwtunnel
> device out of the namespace, with metadata enabled.  The bpf_skb_set_*
> program is attached to tc egress and bpf_skb_get_* is attached to egress
> qdisc.  A ping between two tunnels is used to verify correctness and
> the result of bpf_skb_get_* printed by bpf_trace_printk.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied, thanks.

Next time, propagate the ACK's your received into your commit message
when you post new versions.
