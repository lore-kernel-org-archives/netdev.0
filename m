From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: check warm_boot_count after other
 functions have been reset
Date: Sat, 05 Dec 2015 17:59:31 -0500 (EST)
Message-ID: <20151205.175931.170629319560007846.davem@davemloft.net>
References: <56615367.30002@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	dpieczko@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbbLEW7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 17:59:33 -0500
In-Reply-To: <56615367.30002@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Fri, 4 Dec 2015 08:48:39 +0000

> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> A change in MCFW behaviour means that the net driver must update its record
> of the warm_boot_count by reading it from the ER_DZ_BIU_MC_SFT_STATUS
> register.
> 
> On v4.6.x MCFW the global boot count was incremented when some functions
> needed to be reset to enable multicast chaining, so all functions saw the
> same value.  In that case, the driver needed to increment its
> warm_boot_count when other functions were reset, to avoid noticing it later
> and then trying to reset itself to recover unnecessarily.
> 
> With v4.7+ MCFW, the boot count in firmware doesn't change as that is
> unnecessary since the PFs that have been reset will each receive an MC
> reboot notification.  In that case, the driver re-reads the unchanged
> value.
> 
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied, thanks.
