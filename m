From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access skb->skb_iif
 and skb->dev->ifindex fields
Date: Sat, 30 May 2015 17:51:25 -0700 (PDT)
Message-ID: <20150530.175125.1296198189977879095.davem@davemloft.net>
References: <1432765839-7709-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbbEaAv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 20:51:26 -0400
In-Reply-To: <1432765839-7709-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 27 May 2015 15:30:39 -0700

> classic BPF already exposes skb->dev->ifindex via SKF_AD_IFINDEX extension.
> Allow eBPF program to access it as well. Note that classic aborts execution
> of the program if 'skb->dev == NULL' (which is inconvenient for program
> writers), whereas eBPF returns zero in such case.
> Also expose the 'skb_iif' field, since programs triggered by redirected
> packet need to known the original interface index.
> Summary:
> __skb->ifindex         -> skb->dev->ifindex
> __skb->ingress_ifindex -> skb->skb_iif
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thank you.
