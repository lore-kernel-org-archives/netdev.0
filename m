From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Thu, 10 Feb 2005 19:46:57 -0800
Message-ID: <20050210194657.41fc2907.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
	<20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
	<20050203150821.2321130b.davem@davemloft.net>
	<20050204113305.GA12764@gondor.apana.org.au>
	<20050204154855.79340cdb.davem@davemloft.net>
	<20050204222428.1a13a482.davem@davemloft.net>
	<20050210012304.E25338@almesberger.net>
	<20050210045647.GA15552@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wa@almesberger.net, anton@samba.org, okir@suse.de,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262135AbVBKDsg@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050210045647.GA15552@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2005 15:56:47 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > ? If yes, is this a good idea ?
> 
> Dave mentioned that on sparc64, atomic_inc_and_test is much more
> expensive than the second variant.

Actually, besides the memory barriers themselves, all variants
are equally expensive.

On old i386 chips, the test variants are indeed more expensive.
Linus told me this and there is a note about this in the
atomic_ops.txt file if you look at the current copy :-)
