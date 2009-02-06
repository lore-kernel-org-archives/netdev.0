From: Jan Engelhardt <jengelh@medozas.de>
Subject: NIP6_FMT removal breaks
Date: Fri, 6 Feb 2009 11:36:13 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902061131370.8140@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	davem@davemloft.net
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:51157 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbZBFKgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 05:36:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit b189db5d299c6824780af5590564ff608adb3dea 
(v2.6.28-rc2-82-gb189db5) broke external modules that make use of 
NIP6_FMT. Since NIPQUAD_FMT has been left in place, I would consider the 
removal of NIP6_FMT a regression. Objections?
It is not critical though, as I can easily add an #if LINUX_VERSION_CODE
>= xyz for the external modules.
