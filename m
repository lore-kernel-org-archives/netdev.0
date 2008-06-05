From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [2.6 patch] include/linux/ssb/ssb_driver_gige.h typo fix
Date: Thu, 5 Jun 2008 14:34:35 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806051432220.6496@localhost.localdomain>
References: <20080605182945.GO1469@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:59812 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775AbYFESe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:34:59 -0400
In-Reply-To: <20080605182945.GO1469@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Jun 2008, Adrian Bunk wrote:

> This patch fixes a typo in the name of a config variable.
>
> Reported-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
> ---
> 2aab8eeb46b30baf987c344e1b144caec365373a diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
> index 01fbdf5..942e387 100644
> --- a/include/linux/ssb/ssb_driver_gige.h
> +++ b/include/linux/ssb/ssb_driver_gige.h
> @@ -100,7 +100,7 @@ extern char * nvram_get(const char *name);
>  /* Get the device MAC address */
>  static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
>  {
> -#ifdef CONFIG_BCM947XX
> +#ifdef CONFIG_BCM47XX
>  	char *res = nvram_get("et0macaddr");
>  	if (res)
>  		memcpy(macaddr, res, 6);
>

just FYI, there are more (admittedly aesthetic) references to
BCM947XX in the MIPS directory:

$ grep -r "BCM947XX" *
include/linux/ssb/ssb_driver_gige.h:#ifdef CONFIG_BCM947XX
include/asm-mips/mach-bcm47xx/war.h:#ifndef __ASM_MIPS_MACH_BCM947XX_WAR_H
include/asm-mips/mach-bcm47xx/war.h:#define __ASM_MIPS_MACH_BCM947XX_WAR_H
include/asm-mips/mach-bcm47xx/war.h:#endif /* __ASM_MIPS_MACH_BCM947XX_WAR_H */
$

  whether you want to do anything about those is up to you.

rday
--

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
