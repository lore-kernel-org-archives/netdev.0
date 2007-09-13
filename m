From: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft reboot
Date: Thu, 13 Sep 2007 21:28:12 +0200
Message-ID: <20070913192812.GA12053@xanadu.blop.info>
References: <20070913083918.GA5386@xanadu.blop.info> <1551EAE59135BE47B544934E30FC4FC002AABA5B@nt-irva-0751.brcm.ad.broadcom.com> <20070913154110.GA25781@xanadu.blop.info> <1189706701.9540.84.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([80.248.208.235]:47654 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164AbXIMT2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 15:28:16 -0400
Content-Disposition: inline
In-Reply-To: <1189706701.9540.84.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/09/07 at 11:05 -0700, Michael Chan wrote:
> On Thu, 2007-09-13 at 17:41 +0200, Lucas Nussbaum wrote:
> 
> > # ethtool -i eth0
> > driver: tg3
> > version: 3.65
> > firmware-version: 5703-v2.21a
> > bus-info: 0000:02:02.0
> 
> The firmware is quite old and needs to be upgraded to fix the problem.
> I'll have someone contact you to get it upgraded.

Erm, Wouldn't it be possible to print a warning when the driver loads,
saying that the firmware is outdated ?
-- 
| Lucas Nussbaum                        PhD student |
| lucas.nussbaum@imag.fr        LIG / Projet MESCAL |
| jabber: lucas@nussbaum.fr    +33 (0)6 64 71 41 65 |
| homepage:        http://www-id.imag.fr/~nussbaum/ |
