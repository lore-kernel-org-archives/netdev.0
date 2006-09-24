From: Nathanael Nerode <neroden@fastmail.fm>
Subject: Please remove useless dgrs driver
Date: Sun, 24 Sep 2006 13:00:12 -0400
Message-ID: <20060924170012.GA13939@doctormoo.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-01.nyroc.rr.com ([24.24.2.55]:61321 "EHLO
	ms-smtp-01.nyroc.rr.com") by vger.kernel.org with ESMTP
	id S1751156AbWIXRAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 13:00:24 -0400
Received: from doctormoo (cpe-24-59-106-240.twcny.res.rr.com [24.59.106.240])
	by ms-smtp-01.nyroc.rr.com (8.13.6/8.13.6) with ESMTP id k8OH0JHd000520
	for <netdev@vger.kernel.org>; Sun, 24 Sep 2006 13:00:22 -0400 (EDT)
Received: from neroden by doctormoo with local (Exim 4.63)
	(envelope-from <neroden@fastmail.fm>)
	id 1GRXL0-0003dR-49
	for netdev@vger.kernel.org; Sun, 24 Sep 2006 13:00:18 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An official email from digi.com to Andres Salomon <dilinger@debian.org>
explained:

 Dear Andres:

 After further research, we found that this product was killed in place
 and never reached the market.  We would like to request that this not be
 included.

Copy at http://wiki.debian.org/KernelFirmwareLicensing (this was discovered
during research into firmware licensing).

The drgs driver is useless (no hardware to drive) and should be removed.
The files which should be deleted from the tree are:
        drivers/net/dgrs.c
        drivers/net/dgrs.h
        drivers/net/dgrs_es4h.h
        drivers/net/dgrs_plx9060.h
        drivers/net/dgrs_i82596.h
        drivers/net/dgrs_ether.h
        drivers/net/dgrs_asstruct.h
        drivers/net/dgrs_bcomm.h
        drivers/net/dgrs_firmware.c

It will probably also be necessary to delete some stuff from drivers/net/Kconfig
and drivers/net/Makefile, but I assume that this will be trivial for any
net maintainer.

Thanks in advance for doing this.

-- 
Nathanael Nerode  <neroden@fastmail.fm>

"(Instead, we front-load the flamewars and grudges in
the interest of efficiency.)" --Steve Lanagasek,
http://lists.debian.org/debian-devel/2005/09/msg01056.html
