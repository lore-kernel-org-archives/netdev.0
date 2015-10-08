From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Thu, 08 Oct 2015 05:07:38 -0700 (PDT)
Message-ID: <20151008.050738.1767977635761662797.davem@davemloft.net>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839AbbJHLvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:51:50 -0400
In-Reply-To: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  7 Oct 2015 10:16:09 +0200

> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
> forwarding"), we also need to clear the skb->sender_cpu when moving
> from RX to TX via skb_do_redirect() due to the shared location of
> napi_id (used on RX) and sender_cpu (used on TX).
> 
> Fixes: 27b29f63058d ("bpf: add bpf_redirect() helper")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
