From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: PATCH v4 1/5] can: sja1000: cleanups and new OF property
Date: Thu,  6 Feb 2014 12:09:51 +0100
Message-ID: <1391684996-612-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46248 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756025AbaBFLJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 06:09:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Picking up Florian's patches.

Changes since v3:
- Make use of switch statement in sp_populate_of()
  (patch 5/5), tnx Sergei.
- added Tested-by from Andreas Larsson

Changes since v2:
- Dropped patch 1 "can: sja1000: remove unused defines"
- Addressed Marc's comments on patch 4 and 6 (now 3 and 5)

Changes since v1:
- Merge sja1000_of_platform.c into sja1000_platform.c (patch 4)

The first part of this series performs serveral small cleanups
(patches 1 and 2).

Florian further writes:

===

Patch 3 merges sja1000_of_platform.c into sja1000_platform.c.
Changes are pretty conservatives (mostly copy/paste/move). IRQ
is treated differently in the OF and non-OF versions, thus this
is where the fused version differs the most.

The final part introduces the 'reg-io-width' binding (already used
by some other drivers) to perform a similar job as what was done
with IORESOURCE_MEM_XXBIT. This is needed on my system to correctly
take into account the aliasing of the address bus.

All patches were tested using OF boot on my OMAP3 system with a
memory-mapped SJA1000. Thus, the non-OF path is not tested, as
I do not have a platform data at hand.

Regards,
Florian

v1: http://thread.gmane.org/gmane.linux.kernel/1637835
v2: http://thread.gmane.org/gmane.linux.can/4831

===

Marc
