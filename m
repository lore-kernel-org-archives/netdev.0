From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/3] ep93xx_eth: three fixes for 2.6.19
Date: Sun, 29 Oct 2006 14:03:39 +0100
Message-ID: <20061029130339.GA6900@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:57516 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S965182AbWJ2NDm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 08:03:42 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes three issues in ep93xx_eth.  The first fix is for
an RX/TX lockup bug due to mishandling of the RX/TXstatus rings in the
driver, and is a showstopper.  The second and third aren't really
showstopper bugs, but real issues nevertheless, and easy enough to fix.

Please apply for 2.6.19 -- thanks!
