From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH]: cpmac bugfixes and enhancements
Date: Wed, 14 May 2008 01:31:16 +0200
Message-ID: <200805140131.16473.matteo@openwrt.org>
References: <200805041904.22726.matteo@openwrt.org> <200805140058.32890.matteo@openwrt.org> <20080513160642.a96dccbf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ralf@linux-mips.org, nbd@openwrt.org,
	ejka@imfi.kspu.ru, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out113.alice.it ([85.37.17.113]:3745 "EHLO
	smtp-out113.alice.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757250AbYEMXbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 19:31:23 -0400
In-Reply-To: <20080513160642.a96dccbf.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il Wednesday 14 May 2008 01:06:42 Andrew Morton ha scritto:
> On Wed, 14 May 2008 00:58:32 +0200 Matteo Croce <matteo@openwrt.org> wrote:
> 
> > This one is cleaner:
> > 
> > 
> > Signed-off-by: Matteo Croce <matteo@openwrt.org>
> > Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> 
> It has no changelog.  We can neither effectively review it nor commit
> it without one.
> 
> Each bugfix and each enhancement should be described, please.
> 

Here's the changelog:

* Resolve some locking issues using atomic_inc/atomic_dec
* move status code in cpmac_check_status
* unmark the BROKEN flag in Kconfig
* move code which should have been in platform code in arch/mips/ar7/platform.c
* fixed an IRQ storm which lets the kernel hang
* fixed a double call to netif_start_queue which causes a kernel panic
* don't fail to register the PHY, works on many devices now
