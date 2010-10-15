From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/6] r8169: check dma mapping failures
Date: Fri, 15 Oct 2010 15:41:58 +0200
Message-ID: <20101015134158.GA4417@electric-eye.fr.zoreil.com>
References: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denis Kirjanov <kirjanov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-139-115-126.adslgp.cegetel.net ([88.139.115.126]:35277 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755742Ab0JONnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 09:43:07 -0400
Content-Disposition: inline
In-Reply-To: <1287144922-3297-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> :
> Check possible dma mapping errors and do clean up if it happens,
> when sending frames stop the tx queue.

Almost ok: NETDEV_TX_BUSY can not be used like that. Afaik the DMA
failure path in the driver really wants a NETDEV_TX_OK (and a device
stats update, though missing in tg3 ?).

Actually the former NETDEV_TX_BUSY condition mostly checks for a bug.

-- 
Ueimor
