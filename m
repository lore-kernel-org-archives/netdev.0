From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: fec: reset fep link status in
 suspend function
Date: Wed, 10 Dec 2014 14:54:24 -0500 (EST)
Message-ID: <20141210.145424.35618035568083747.davem@davemloft.net>
References: <1418205289-7730-1-git-send-email-b38611@freescale.com>
	<1418205289-7730-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932874AbaLJTy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:54:27 -0500
In-Reply-To: <1418205289-7730-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 10 Dec 2014 17:54:47 +0800

> +	/*
> +	 * SOC supply clock to phy, when clock is disabled, phy link down
> +	 * SOC control phy regulator, when regulator is disabled, phy link down
> +	 */

Comments in the networking should be of the form:

	/* Like
	 * this.
	 */

Not:

	/*
	 * Like
	 * this.
	 */
