From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: mvneta: Fix highmem support in the non-TSO
 egress path
Date: Mon, 26 Jan 2015 14:40:18 -0800 (PST)
Message-ID: <20150126.144018.1498585339071089162.davem@davemloft.net>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1421844850-30886-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@arm.linux.org.uk,
	B38611@freescale.com, fabio.estevam@freescale.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45658 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167AbbAZWkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:40:19 -0500
In-Reply-To: <1421844850-30886-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Wed, 21 Jan 2015 09:54:09 -0300

> +		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr)) {
> +
> +			/* The first descriptor is either a TSO header or
> +			 * the linear part of the skb.
> +			 */

This empty line is unnecessary and inapparopriate, please remove it.
