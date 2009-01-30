From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: Fix Wake-on-LAN support
Date: Thu, 29 Jan 2009 17:31:33 -0800 (PST)
Message-ID: <20090129.173133.268065861.davem@davemloft.net>
References: <20090128203545.GA13928@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, afleming@freescale.com, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55247
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754752AbZA3Bbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:31:36 -0500
In-Reply-To: <20090128203545.GA13928@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Wed, 28 Jan 2009 23:35:45 +0300

> commit 0f0ca340e57bd7446855fefd07a64249acf81223 ("phy: power
> management support") caused a regression in the gianfar driver.
> 
> Now phylib turns off PHY power during suspend, and thus WOL
> doesn't work anymore.
> 
> This patch workarounds the issue by enabling wakeup in the MDIO
> device, i.e. just restores the old behaviour for the gianfar
> driver. Note that this way all PHYs on a given MDIO bus won't
> be turned off during suspend, which isn't good from the power
> saving point of view.
> 
> A proper, per netdevice wakeup management support will need
> a bit reworked phylib suspend/resume logic.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks Anton.
