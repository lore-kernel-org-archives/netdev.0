From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Tue, 17 Mar 2009 23:06:25 +0100
Message-ID: <20090317220625.GA5038@electric-eye.fr.zoreil.com>
References: <200903172034.55241.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Karsten Wiese <fzu@wemgehoertderstaat.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50202 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752984AbZCQWDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 18:03:32 -0400
Content-Disposition: inline
In-Reply-To: <200903172034.55241.fzu@wemgehoertderstaat.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten Wiese <fzu@wemgehoertderstaat.de> :
> 
> Only adjust the NAPI bits of the interruptmask, if netif_rx_schedule_prep()
> returns true.
> Without this, I see interrupt storms here using 2.6.29-rcx and 2.6.27.19 and
> device needed rmmod r8169 + modprobe r8169 to start working.

How the patch is supposed to work is not completely clear to me.

Can you elaborate a bit ?

-- 
Ueimor
