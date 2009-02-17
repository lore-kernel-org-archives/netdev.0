From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH 0/2] fec: move ColdFire setup code out of FEC driver
Date: Tue, 17 Feb 2009 10:53:01 +1000
Message-ID: <200902170053.n1H0r1WP002062@localhost.localdomain>
Cc: gerg@uclinux.org, netdev@vger.kernel.org
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:49283 "EHLO
	snapgear.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751043AbZBQAx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 19:53:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Sascha,

The following 2 patches move the ColdFire specific FEC setup code
into the ColdFire CPU platform setup code.

There is still a little remaining legacy code that needs taking
care of in fec.c. The flash reading MAC setup code and the MII
link interrupts of the 5272 are still in there.

Regards
Greg


