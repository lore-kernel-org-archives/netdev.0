From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] samples/bpf: Add tunnel set/get tests.
Date: Tue, 16 Aug 2016 09:16:10 -0700
Message-ID: <20160816161608.GA77310@ast-mbp.thefacebook.com>
References: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36815 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcHPQeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 12:34:20 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so5731981pfg.3
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 09:33:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 07:03:01AM -0700, William Tu wrote:
> The patch creates sample code exercising bpf_skb_{set,get}_tunnel_key,
> and bpf_skb_{set,get}_tunnel_opt for GRE, VXLAN, and GENEVE.  A native
> tunnel device is created in a namespace to interact with a lwtunnel
> device out of the namespace, with metadata enabled.  The bpf_skb_set_*
> program is attached to tc egress and bpf_skb_get_* is attached to egress
> qdisc.  A ping between two tunnels is used to verify correctness and
> the result of bpf_skb_get_* printed by bpf_trace_printk.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

nice test. thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
