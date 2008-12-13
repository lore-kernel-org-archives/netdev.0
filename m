From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 28/33] sfc: Use mutex_lock_interruptible() for ethtool
 EEPROM access
Date: Fri, 12 Dec 2008 22:06:32 -0800 (PST)
Message-ID: <20081212.220632.41364430.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125922.GB10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57115
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755198AbYLMGGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:06:30 -0500
In-Reply-To: <20081212125922.GB10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:59:23 +0000

> ethtool must contend with the MTD driver for the SPI bus lock, which
> may carry out long operations such as flash erase.  Allow it to be
> interrupted while waiting.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
