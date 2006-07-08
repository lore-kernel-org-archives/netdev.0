From: Christoph Hellwig <hch@infradead.org>
Subject: Re: starting mc triggers lockdep
Date: Sat, 8 Jul 2006 14:46:21 +0100
Message-ID: <20060708134621.GA10549@infradead.org>
References: <E1Fz33I-0006vG-00@gondolin.me.apana.org.au> <1152352400.3120.19.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davej@redhat.com,
	mingo@elte.hu, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:31437 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S964832AbWGHNq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 09:46:28 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1152352400.3120.19.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 08, 2006 at 11:53:20AM +0200, Arjan van de Ven wrote:
> > Did I miss something?
> 
> is it not possible to nfs export /sys, and then mount it over loopback?

No, it's not.  A filesystem needs dedicated routines to support nfs
exporting and sysfs doesn't have those.

