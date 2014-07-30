From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: stmmac: add platform init/exit for
 Altera's ARM socfpga
Date: Wed, 30 Jul 2014 15:12:20 -0700 (PDT)
Message-ID: <20140730.151220.2195718419905210967.davem@davemloft.net>
References: <1406574478-19343-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com, vbridger@altera.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbaG3WMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 18:12:21 -0400
In-Reply-To: <1406574478-19343-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Mon, 28 Jul 2014 14:07:58 -0500

> This patch adds platform init/exit functions and modifications to support
> suspend/resume for the Altera Cyclone 5 SOC Ethernet controller. The platform
> exit function puts the controller into reset using the socfpga reset
> controller driver. The platform init function sets up the Synopsys mac by
> first making sure the Ethernet controller is held in reset, programming the
> phy mode through external support logic, then deasserts reset through
> the socfpga reset manager driver.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V3: respin for net-next after phy_suspend was exported by libphy
>     per suggestion from Florian. No changes to patch from V2 -> V3.
> V2: Address review comments - add line break before structure decl

Applied, thank you.
