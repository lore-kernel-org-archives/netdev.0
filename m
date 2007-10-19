From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 5/8] [MV643XX_ETH] Remove SHARED_REGS register address bias
Date: Fri, 19 Oct 2007 13:09:07 +0200
Message-ID: <20071019110907.GK16037@xi.wantstofly.org>
References: <20071019021117.GG16037@xi.wantstofly.org> <ada7iljepfx.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:53959 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbXJSLJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 07:09:10 -0400
Content-Disposition: inline
In-Reply-To: <ada7iljepfx.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2007 at 08:46:58PM -0700, Roland Dreier wrote:

>  > +static void __iomem *mv643xx_eth_base;
> 
>  > +	return readl(((void __iomem *)mv643xx_eth_base) + offset);
> 
> Given the declaration of mv643xx_eth_base as void __iomem * already, I
> don't understand why you need the cast to the same type here (and
> elsewhere in the driver).

Makes sense, fixed.
