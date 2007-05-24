From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] forcedeth: version bump
Date: Thu, 24 May 2007 18:03:05 -0400
Message-ID: <46560B99.9020406@garzik.org>
References: <465237F5.2010208@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48549 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbXEXWDJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 18:03:09 -0400
In-Reply-To: <465237F5.2010208@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch bumps up the version.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> ------------------------------------------------------------------------
> 
> --- old/drivers/net/forcedeth.c	2007-05-21 20:09:03.000000000 -0400
> +++ new/drivers/net/forcedeth.c	2007-05-21 20:10:32.000000000 -0400
> @@ -112,6 +112,7 @@
>   *	0.58: 30 Oct 2006: Added support for sideband management unit.
>   *	0.59: 30 Oct 2006: Added support for recoverable error.
>   *	0.60: 20 Jan 2007: Code optimizations for rings, rx & tx data paths, and stats.
> + *	0.61: 21 May 2007: Fix power management code, cpu mask, and added vitesse phy.
>   *
>   * Known bugs:
>   * We suspect that on some hardware no TX done interrupts are generated.

The standard for kernel drivers these days is to rely on the 
permanent-for-eternity kernel changelog stored in git.

So please just remove the entire history from the C source code.  It's 
just patch noise...


> @@ -128,7 +129,7 @@
>  #else
>  #define DRIVERNAPI
>  #endif
> -#define FORCEDETH_VERSION		"0.60"
> +#define FORCEDETH_VERSION		"0.61"
>  #define DRV_NAME			"forcedeth"

obviously the rest of this patch is OK.  But due to earlier patch 
rejections, I will not apply it, and will assume it will reappear when 
you resend other patches.

Finally, I would suggest keeping up with the kernel's "bug fix" 
2.6.X-rcY release candidate cycles.  These changes ARE bug fixes, I 
agree, but they still should not be appearing at the last minute.  That 
gives us little time to ensure the fixes do not cause regressions.

	Jeff


