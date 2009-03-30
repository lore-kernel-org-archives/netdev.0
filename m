From: David Miller <davem@davemloft.net>
Subject: Re: skb_segment() questions
Date: Mon, 30 Mar 2009 13:57:48 -0700 (PDT)
Message-ID: <20090330.135748.264670066.davem@davemloft.net>
References: <20090329020701.GA9983@gondor.apana.org.au>
	<20090328.233929.160905643.davem@davemloft.net>
	<1238403045.854.39.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jamesclhuang@gmail.com,
	netdev@vger.kernel.org
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbZC3U6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 16:58:00 -0400
In-Reply-To: <1238403045.854.39.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Mon, 30 Mar 2009 09:50:45 +0100

> On Sat, 2009-03-28 at 23:39 -0700, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Sun, 29 Mar 2009 10:07:01 +0800
> > 
> > > gso: Fix support for linear packets
> > > 
> > > When GRO/frag_list support was added to GSO, I made an error
> > > which broke the support for segmenting linear GSO packets (GSO
> > > packets are normally non-linear in the payload).
> > > 
> > > These days most of these packets are constructed by the tun
> > > driver, which prefers to allocate linear memory if possible.
> > > This is fixed in the latest kernel, but for 2.6.29 and earlier
> > > it is still the norm.
> > > 
> > > Therefore this bug causes failures with GSO when used with tun
> > > in 2.6.29.
> > > 
> > > Reported-by: James Huang <jamesclhuang@gmail.com>
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Applied, thanks.
> 
> This is needed in -stable too, fwiw. Fixes e.g. virtio guest->remote
> with 2.6.29 host:
> 
>   https://bugzilla.redhat.com/490266

I know, I'll queue it up.
