From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [RESEND^2] ssb: mark ssb_bus_register as __maybe_unused
Date: Tue, 19 Jan 2016 19:26:25 +0000 (UTC)
Message-ID: <20160119192625.5575F6061B@smtp.codeaurora.org>
References: <6063400.39vor3soEb@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36366 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932980AbcAST0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:26:25 -0500
In-Reply-To: <6063400.39vor3soEb@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The SoC variant of the ssb code is now optional like the other
> ones, which means we can build the framwork without any
> front-end, but that results in a warning:
> 
> drivers/ssb/main.c:616:12: warning: 'ssb_bus_register' defined but not used [-Wunused-function]
> 
> This annotates the ssb_bus_register function as __maybe_unused to
> shut up the warning. A configuration like this will not work on
> any hardware of course, but we still want this to silently build
> without warnings if the configuration is allowed in the first
> place.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 845da6e58e19 ("ssb: add Kconfig entry for compiling SoC related code")
> Acked-by: Michael Buesch <m@bues.ch>

Thanks, applied to wireless-drivers.git.

Kalle Valo
