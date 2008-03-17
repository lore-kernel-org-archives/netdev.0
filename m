From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/7][MV643XX_ETH] various cleanups
Date: Mon, 17 Mar 2008 20:15:46 +0100
Message-ID: <20080317191546.GA17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37913 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbYCQTPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:15:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series performs various cleanups of mv643xx_eth, and moves
it into the direction of being able to be instantiated multiple times
-- which is currently not possible due to the driver using static
variables, identifying ports by their port index within the single
supported instance[*] instead of a pointer to a describing structure,
and such.

The goal of multiple instantiation isn't achieved yet by this patch
set, since it requires some changes in how mv643xx_eth platform
devices are instantiated which in turn requires some changes in
arch/{ppc,powerpc} which haven't been fully sorted out and agreed
upon yet -- but this patch set is a step in the general direction,
and the maintainer has informally ACKed these patches previously
(in private mail), so I'm seeking wider feedback on them now.

Comments?


thanks,
Lennert

[*] A single mv643xx_eth instance can support up to 3 ethernet
    ports, but multiple mv643xx_eth Si blocks can exist within a
    single chip, requiring instantiation of multiple mv643xx_eth
    instances.
