From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] virtio_net: Recycle some more rx buffer pages
Date: Sun, 16 Nov 2008 23:08:27 -0800 (PST)
Message-ID: <20081116.230827.88286434.davem@davemloft.net>
References: <200811171344.57410.rusty@rustcorp.com.au>
	<20081116.194505.140648013.davem@davemloft.net>
	<200811171735.44025.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59764
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751706AbYKQHI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:08:27 -0500
In-Reply-To: <200811171735.44025.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 17 Nov 2008 17:35:43 +1030

> On Monday 17 November 2008 14:15:05 David Miller wrote:
> > From: Rusty Russell <rusty@rustcorp.com.au>
> > Date: Mon, 17 Nov 2008 13:44:57 +1030
> >
> > > @@ -82,6 +82,16 @@ static void give_a_page(struct virtnet_info *vi,
> > > struct page *page)
> >
> > -E_EMAIL_CLIENT_NEWLINES
> 
> Each time we re-fill the recv queue with buffers, we allocate
> one too many skbs and free it again when adding fails. We should
> recycle the pages allocated in this case.
> 
> A previous version of this patch made trim_pages() trim trailing
> unused pages from skbs with some paged data, but this actually
> caused a barely measurable slowdown.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (use netdev_priv)

-ETOOLATE, and...

> -			give_a_page(dev->priv, skb_shinfo(skb)->frags[i].page);

this wouldn't have applied to net-next-2.6, the dev->priv reads
netdev_priv(dev) there.

Anyways, as I said in my other reply I fixed all of this up because
I was tired of waiting... :)

