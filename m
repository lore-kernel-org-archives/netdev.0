From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/6] r8169: check dma mapping failures
Date: Mon, 18 Oct 2010 09:01:15 +0200
Message-ID: <20101018070114.GB2303@redhat.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
 <20101015134158.GA4417@electric-eye.fr.zoreil.com>
 <AANLkTimwwhBJdoXcvSt-wdTGv5biHJj094s0TutFM66N@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Denis Kirjanov <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752977Ab0JRG6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 02:58:54 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTimwwhBJdoXcvSt-wdTGv5biHJj094s0TutFM66N@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 06:23:55PM +0400, Denis Kirjanov wrote:
> Right, we should pass TX_BUSY to upper layers only when the device hw
> queue is full
> 
> On Fri, Oct 15, 2010 at 5:41 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Stanislaw Gruszka <sgruszka@redhat.com> :
> >> Check possible dma mapping errors and do clean up if it happens,
> >> when sending frames stop the tx queue.
> >
> > Almost ok: NETDEV_TX_BUSY can not be used like that. Afaik the DMA
> > failure path in the driver really wants a NETDEV_TX_OK (and a device
> > stats update, though missing in tg3 ?).

Ok, I will change that and repost on top of currently applied Eric's 
patch.

Stanislaw
