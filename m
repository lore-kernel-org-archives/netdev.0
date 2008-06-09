From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] tg3: Fix 5761 WOL
Date: Mon, 09 Jun 2008 15:42:49 -0700 (PDT)
Message-ID: <20080609.154249.231309954.davem@davemloft.net>
References: <1213046689.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33841
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763555AbYFIWmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:42:49 -0400
In-Reply-To: <1213046689.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 9 Jun 2008 11:39:05 -0700

> On 5761 non-e devices, two problems prevent the administrator from
> overriding the WOL settings in the device's NVRAM.
> 
> The first problem is that GPIO 0 and GPIO 2 have been swapped.  This
> change prevented the administrator from turning on WOL when it is
> disabled in NVRAM.  The fix is to add a new path for the 5761 that
> swaps the two GPIOs in the code as well.
> 
> The second problem is that GPIO 1 could not be toggled by the driver
> because the GPIO is shared with the debug UART GPIO.  This will prevent
> the administrator from being able to turn WOL off if it was enabled in
> NVRAM.  The fix is to always disable the debug UART after a GRC reset.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
