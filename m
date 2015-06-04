From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: introduce bpf_clone_redirect() helper
Date: Wed, 03 Jun 2015 20:17:27 -0700 (PDT)
Message-ID: <20150603.201727.1848194519762843477.davem@davemloft.net>
References: <1433286194-5246-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbFDDR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:17:28 -0400
In-Reply-To: <1433286194-5246-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  2 Jun 2015 16:03:14 -0700

> Allow eBPF programs attached to classifier/actions to call
> bpf_clone_redirect(skb, ifindex, flags) helper which will
> mirror or redirect the packet by dynamic ifindex selection
> from within the program to a target device either at ingress
> or at egress. Can be used for various scenarios, for example,
> to load balance skbs into veths, split parts of the traffic
> to local taps, etc.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
