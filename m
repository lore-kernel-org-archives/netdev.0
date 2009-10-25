From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 6/9] ser_gigaset: checkpatch cleanup
Date: Sun, 25 Oct 2009 20:37:05 +0000
Message-ID: <20091025203705.273e1c14@lxorguk.ukuu.org.uk>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
	<20091023-patch-gigaset-06.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:56292 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753707AbZJYUfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 16:35:32 -0400
In-Reply-To: <20091023-patch-gigaset-06.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Oct 2009 20:30:27 +0100 (CET)
Tilman Schmidt <tilman@imap.cc> wrote:

> Duly uglified as demanded by checkpatch.pl.
> 
> Impact: cosmeti

Umm ??

> -		if (!(bcs->tx_skb = skb_dequeue(&bcs->squeue)))
> +		nextskb = skb_dequeue(&bcs->squeue);
> +		if (!nextskb)
>  			/* no skb either, nothing to do */
>  			return;
> +		bcs->tx_skb = nextskb;

This does not do the same thing as before

Previously the NULL case assigned to bcs->tx_skb, now it does not.
