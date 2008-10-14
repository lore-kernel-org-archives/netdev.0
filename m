From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS
 dependency
Date: Tue, 14 Oct 2008 15:44:22 -0700 (PDT)
Message-ID: <20081014.154422.192817982.davem@davemloft.net>
References: <1224023293-8592-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751095AbYJNWop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 18:44:45 -0400
In-Reply-To: <1224023293-8592-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 14 Oct 2008 17:28:13 -0500

> PHY Lib and DSA expect request_irq and other such functions to exist.
> S390 doesn't support those functions, however we should mark the actual
> dependency, which is generic hardirq support, rather than explicitly
> depend on !S390.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> This makes more sense to me, but I could be missing something?

GENERIC_HARDIRQS is not the correct dependency.

Not all architectures use the generic IRQ layer, yet have
support for interrupts (request_irq(), free_irq(), etc.)

Two such platforms are 32-bit sparc and m68k.
