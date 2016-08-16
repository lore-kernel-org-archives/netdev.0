From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] samples/bpf: Add tunnel set/get tests.
Date: Tue, 16 Aug 2016 17:00:08 +0200
Message-ID: <57B32A78.2000105@iogearbox.net>
References: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: William Tu <u9012063@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38324 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbcHPPAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:00:39 -0400
In-Reply-To: <1471356181-32069-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2016 04:03 PM, William Tu wrote:
> The patch creates sample code exercising bpf_skb_{set,get}_tunnel_key,
> and bpf_skb_{set,get}_tunnel_opt for GRE, VXLAN, and GENEVE.  A native
> tunnel device is created in a namespace to interact with a lwtunnel
> device out of the namespace, with metadata enabled.  The bpf_skb_set_*
> program is attached to tc egress and bpf_skb_get_* is attached to egress
> qdisc.  A ping between two tunnels is used to verify correctness and
> the result of bpf_skb_get_* printed by bpf_trace_printk.
>
> Signed-off-by: William Tu <u9012063@gmail.com>

For net-next tree. LGTM, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
