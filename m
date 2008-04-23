From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/5] mv643xx_eth: allow multiple instances
Date: Thu, 24 Apr 2008 01:26:42 +0200
Message-ID: <20080423232642.GB17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@cam.org>
To: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:60256 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbYDWX0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 19:26:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This (bisectable) patch series (posted previously to netdev@ on Mar
17 and on Mar 19) allows instantiating multiple mv643xx_eth instances,
which is necessary for newer chips that contain multiple mv643xx_eth
silicon blocks, and adds support for programming mv643xx_eth's mbus
address window registers.

These five patches were not merged in the initial batch of
mv643xx_eth patches that went into 2.6.25-git because they depend
on a0916bd64a0e6636f0161480e04057c89e90c5da ("[POWERPC] mv643xx_eth:
Prepare to support multiple silicon blocks") to be merged first,
which has now been merged (via the powerpc tree.)
