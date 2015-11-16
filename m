From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: smsc911x: Reset PHY during initialization
Date: Mon, 16 Nov 2015 14:43:27 -0500 (EST)
Message-ID: <20151116.144327.1187971163162596209.davem@davemloft.net>
References: <000401d11ddf$18dffce0$4a9ff6a0$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	steve.glendinning@shawell.net
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40301 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbKPTn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:43:29 -0500
In-Reply-To: <000401d11ddf$18dffce0$4a9ff6a0$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Fri, 13 Nov 2015 09:46:59 +0300

> On certain hardware after software reboot the chip may get stuck and fail
> to reinitialize during reset. This can be fixed by ensuring that PHY is
> reset too.
> 
> Old PHY resetting method required operational MDIO interface, therefore
> the chip should have been already set up. In order to be able to function
> during probe, it is changed to use PMT_CTRL register.
> 
> The problem could be observed on SMDK5410 board.
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Applied.
