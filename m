From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bcm43xx-softmac: optimization of DMA bitfields.]
Date: Wed, 16 Aug 2006 17:42:43 +0200
Message-ID: <1155742963.3600.39.camel@ux156>
References: <44E33B7A.3060804@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>, Michael Buesch <mb@bu3sch.de>,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38287 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932082AbWHPPmb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 11:42:31 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44E33B7A.3060804@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-16 at 10:36 -0500, Larry Finger wrote:
> +	/* Boolean. Is this a TX ring? */
> +	u8 tx
> +	/* Boolean. 64bit DMA if true, 32bit DMA otherwise. */
> +	u8 dma64;

does that compile?

johannes
