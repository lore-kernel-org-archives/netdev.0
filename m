From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 00/24 for-2.6.25] DM9000 updates for 2.6.25
Date: Tue, 05 Feb 2008 00:01:59 +0000
Message-ID: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58710 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758823AbYBEAIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is a series of updates for the DM9000
driver, to tidy-up some of the source, stop the accesses
to the PHY and EEPROM sitting and spinning with locks
held, and to add ethtool support.

This set includes a pair of patches from Laurent Pinchart
for addition platform-data based configuration, please
apply these from this if you can attribute these correctly
to Laurent, otherwise ask Laurent to resubmit. I have
signed-off-by both these patches, but would be equally
happy acking them.

The only missing item in this series is to replace the
old timer based polling code. This series has been sitting
long enough on my own trees, and having MII link status
reports is not a driver-threatening bug.

Hopefully this series meets up to everyone's approval and
can be applied whilst the current merge window is upon us.

-- 
Ben
