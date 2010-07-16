From: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Subject: [PATCH 0/2] Removing dead code
Date: Fri, 16 Jul 2010 14:28:56 +0200
Message-ID: <cover.1279282865.git.qy03fugy__33178.8671821871$1279283394$gmane$org@stud.informatik.uni-erlangen.de>
References: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
 <redwood56-reply-1-miltonm@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: Milton Miller <miltonm@bga.com>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43399 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965280Ab0GPM3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 08:29:03 -0400
Content-Disposition: inline
In-Reply-To: <redwood56-reply-1-miltonm@bga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all!

I merged the two patches from Christoph Egger[1] to remove the
REDWOOD_[456] config depends. And wrote a second patch, which removes
the redwood/mtd mapping module. I hope this is now acceptable to bring
it into the kernel, if this options are really dead.       

Regards

        Christian Dietrich

[0] http://vamos1.informatik.uni-erlangen.de/
[1] Message-Id: <adba61f63f4439ac17f2e428429f01ae5e65ab15.1279110895.git.siccegge@cs.fau.de>

Christian Dietrich (2):
  Remove REDWOOD_[456] config options and conditional code
  Removed redwood/mtd mapping

 arch/powerpc/platforms/40x/Kconfig |   16 ----
 drivers/mtd/maps/Kconfig           |    8 --
 drivers/mtd/maps/Makefile          |    1 -
 drivers/mtd/maps/redwood.c         |  174 ------------------------------------
 drivers/net/Kconfig                |    2 +-
 drivers/net/smc91x.h               |   37 --------
 6 files changed, 1 insertions(+), 237 deletions(-)
 delete mode 100644 drivers/mtd/maps/redwood.c

