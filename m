From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 5/8] [MV643XX_ETH] Remove SHARED_REGS register address bias
Date: Thu, 18 Oct 2007 20:46:58 -0700
Message-ID: <ada7iljepfx.fsf@cisco.com>
References: <20071019021117.GG16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:46306 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758297AbXJSDrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 23:47:03 -0400
In-Reply-To: <20071019021117.GG16037@xi.wantstofly.org> (Lennert Buytenhek's message of "Fri, 19 Oct 2007 04:11:17 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +static void __iomem *mv643xx_eth_base;

 > +	return readl(((void __iomem *)mv643xx_eth_base) + offset);

Given the declaration of mv643xx_eth_base as void __iomem * already, I
don't understand why you need the cast to the same type here (and
elsewhere in the driver).

 - R.
