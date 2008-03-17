From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/5][RFC][MV643XX_ETH] more cleanups
Date: Mon, 17 Mar 2008 21:04:27 +0100
Message-ID: <20080317200427.GA18726@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47056 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758221AbYCQUE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 16:04:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series consists of a couple more mv643xx_eth cleanups.

These cleanups can't be merged yet at this point, as the first one
(which allows instantiating multiple mv643xx_eth instances)
inadvertently breaks ppc/powerpc due to changing instantiation
rules, and the rest of the patches all depend on the first patch.

Nevertheless, I wanted to get this out there for review.
