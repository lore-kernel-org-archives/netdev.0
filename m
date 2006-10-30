From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,try2 0/3] ep93xx_eth: three fixes for 2.6.19
Date: Mon, 30 Oct 2006 19:51:15 +0100
Message-ID: <20061030185115.GA14805@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ray Lehtiniemi <rayl@mail.com>,
	Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:43955 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1030561AbWJ3SvR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:51:17 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes three issues in ep93xx_eth.  The first fix is for
an RX/TX lockup bug due to mishandling of the RX/TXstatus rings in the
driver, and is a showstopper.  The second and third aren't really
showstopper bugs, but real issues nevertheless, and easy enough to fix.

In this new queue, I've replaced the third patch, which modified
ep93xx_eth to only printk for non-FIFO overrun-type RX errors, by a
patch which stops ep93xx_eth reporting RX errors at all, since it makes
little sense, and the regular error counters should be sufficient.

Please apply for 2.6.19 -- thanks!
