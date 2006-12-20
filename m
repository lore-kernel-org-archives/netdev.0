From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Bug 7596 - Potential performance bottleneck for Linxu TCP
Date: Tue, 19 Dec 2006 21:11:24 -0800
Message-ID: <20061219211124.061b5c2d@localhost.localdomain>
References: <20061219103756.38f7426c@freekitty>
	<E1Gwokt-00050T-00@gondolin.me.apana.org.au>
	<20061219.185525.41636407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mingo@elte.hu, akpm@osdl.org,
	wenji@fnal.gov, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:35579 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964889AbWLTFMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 00:12:40 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061219.185525.41636407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Dec 2006 18:55:25 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 20 Dec 2006 10:52:19 +1100
> 
> > Stephen Hemminger <shemminger@osdl.org> wrote:
> > > I noticed this bit of discussion in tcp_recvmsg. It implies that a better
> > > queuing policy would be good. But it is confusing English (Alexey?) so
> > > not sure where to start.
> > 
> > Actually I think the comment says that the current code isn't the
> > most elegant but is more efficient.
> 
> It's just explaining the hierarchy of queues that need to
> be purged, and in what order, for correctness.
> 
> Alexey added that code when I mentioned to him, right after
> we added the prequeue, that it was possible process the
> normal backlog before the prequeue, which is illegal.
> In fixing that bug, he added the comment we are discussing.

It was the realtime/normal comments that piqued my interest.
Perhaps we should either tweak process priority or remove
the comments.
