From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] sfc: Fix test for MDIO read failure
Date: Mon, 02 Mar 2009 03:26:17 -0800 (PST)
Message-ID: <20090302.032617.91189355.davem@davemloft.net>
References: <1235775847.3164.6.camel@achroite>
	<1235775972.3164.17.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752934AbZCBL0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 06:26:36 -0500
In-Reply-To: <1235775972.3164.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 27 Feb 2009 23:06:12 +0000

> Commit 27dd2caca4eabe7c13a052b7456495ba75535e6a changed
> mdio_clause45_check_mmds() to read both DEVS0 and DEVS1 registers and
> to combine their values into an unsigned 32-bit mask.  This made the
> following test for a negative (failure) value useless.  Fix it to
> check whether either read failed.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
