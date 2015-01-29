From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: DMA threshold mode or SF mode can be different
 among multiple device instance
Date: Thu, 29 Jan 2015 15:28:39 -0800 (PST)
Message-ID: <20150129.152839.1317212559062872075.davem@davemloft.net>
References: <1422521699-14096-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	adi-buildroot-devel@lists.sourceforge.net, sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbbA2X2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:28:41 -0500
In-Reply-To: <1422521699-14096-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Thu, 29 Jan 2015 16:54:59 +0800

>  		/* Try to bump up the dma threshold on this failure */
> -		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
> +		if (unlikely(priv->xstats.threshold != SF_DMA_MODE) &&
> +			(tc <= 256)) {

This is not indented properly.  The second line of the conditional
should start precisely at the first column after the openning
parenthesis of the if() statement.
