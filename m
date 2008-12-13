From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/33] sfc: Clean up waits for flash/EEPROM operations
Date: Fri, 12 Dec 2008 21:33:59 -0800 (PST)
Message-ID: <20081212.213359.215131885.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212125100.GG10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751119AbYLMFd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:33:58 -0500
In-Reply-To: <20081212125100.GG10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:51:01 +0000

> Make falcon_spi_wait() ignore the write timer - it is only relevant to
> write commands, it only works for the device that contains VPD, and it
> might not be initialised properly at all.
> 
> Rename falcon_spi_fast_wait() to falcon_spi_wait_write(), reflecting
> its use, and make it wait up to 10 ms (not 1 ms) since buffered writes
> to EEPROM may take this long to complete.
> 
> Make both wait functions sleep instead of busy-waiting.
> 
> Replace wait for command completion at top of falcon_spi_cmd() with a
> single poll; no command should be running when the function starts.
> 
> Correct some comments.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
