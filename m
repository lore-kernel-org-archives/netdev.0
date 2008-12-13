From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/33] sfc: Work around unreliable strap pins
Date: Fri, 12 Dec 2008 21:34:34 -0800 (PST)
Message-ID: <20081212.213434.250861467.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125127.GH10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36642
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752211AbYLMFed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:34:33 -0500
In-Reply-To: <20081212125127.GH10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:51:28 +0000

> The SFC4000 has strap pins indicating the presence of SPI flash and/or
> EEPROM.  These pins are also used for GPIO, and in some cases they may
> be read wrongly at reset.  However, on production boards it must boot
> from one or the other device, so we can assume the boot device is
> present and read the board config from there.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
