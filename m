From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/6] mv643xx.c: Add basic device tree support.
Date: Tue, 31 Jul 2012 20:18:32 +0000
Message-ID: <201207312018.33432.arnd@arndb.de>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk> <201207311823.54857.arnd@arndb.de> <20120731192458.GE28852@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ian Molton <ian.molton@codethink.co.uk>,
	linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50123 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab2GaUSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 16:18:39 -0400
In-Reply-To: <20120731192458.GE28852@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 31 July 2012, Andrew Lunn wrote:
> This pattern is used in other places, e.g. when creating the
> clocks. The macro MV643XX_ETH_NAME is also used when creating the
> platform data, and in the driver itself. 
> 
> Are you suggested we replace this with "mv643xx_eth.0"? Or is adding
> the macro
> 
> #define MV643XX_ETH_NAME0 "mv643xx_eth.0" 
> 
> in include/linux/mv643xx_eth.h O.K, since grep will find it, and
> induce the grep'er to perform a second grep on the macro?

I meant the former. Just remove the macro entirely, or at least
don't add new users.

	Arnd
