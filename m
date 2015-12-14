From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] stmmac: dwmac-sunxi: Call exit cleanup function in
 probe error path
Date: Mon, 14 Dec 2015 16:12:18 -0500 (EST)
Message-ID: <20151214.161218.2057176608170714361.davem@davemloft.net>
References: <1449828229-10720-1-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, maxime.ripard@free-electrons.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, manabian@gmail.com
To: wens@csie.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbbLNVMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:12:20 -0500
In-Reply-To: <1449828229-10720-1-git-send-email-wens@csie.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen-Yu Tsai <wens@csie.org>
Date: Fri, 11 Dec 2015 18:03:49 +0800

> dwmac-sunxi has 2 callbacks that were called from stmmac_platform as
> part of the probe and remove sequences.
> 
> Ater the conversion of dwmac-sunxi into a standalone platform driver,
> the .init function is called before calling into the stmmac driver
> core, but .exit is not called to clean up if stmmac returns an error.
> 
> This patch fixes the probe error path. This properly cleans up and
> releases resources when the driver core fails to probe.
> 
> Cc: Joachim Eastwood <manabian@gmail.com>
> Fixes: 9a9e9a1edee8 ("stmmac: dwmac-sunxi: turn setup callback into a
> 		      probe function")
> Signed-off-by: Chen-Yu Tsai <wens@csie.org>

Applied, thanks.
