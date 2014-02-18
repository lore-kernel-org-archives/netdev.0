From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: update dependency and help text of
 mvneta
Date: Tue, 18 Feb 2014 18:09:18 -0500 (EST)
Message-ID: <20140218.180918.2278994810974129533.davem@davemloft.net>
References: <1392729491-24913-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net,
	gregory.clement@free-electrons.com, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com,
	ezequiel.garcia@free-electrons.com,
	linux-arm-kernel@lists.infradead.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbaBRXJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:09:21 -0500
In-Reply-To: <1392729491-24913-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Tue, 18 Feb 2014 14:18:11 +0100

> With the introduction of the support for Armada 375 and Armada 38x,
> the hidden Kconfig option MACH_ARMADA_370_XP is being renamed to
> MACH_MVEBU_V7. Therefore, the dependency that was used for the mvneta
> driver can no longer work. This commit replaces this dependency by a
> dependency on PLAT_ORION, which is used similarly for the mv643xx_eth
> driver.
> 
> In addition to this, it takes this opportunity to adjust the
> description and help text to indicate that the driver can is also used
> for Armada 38x. Note that Armada 375 cannot use this driver as it has
> a completely different networking unit, which will require a separate
> driver.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Applied, thanks.
