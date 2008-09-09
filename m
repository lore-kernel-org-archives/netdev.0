From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 0/4] atlx: add atl2 support
Date: Tue, 9 Sep 2008 02:12:47 -0400
Message-ID: <20080909061247.GA17834@file.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, jcliburn@gmail.com
To: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbYIIGN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:13:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for atl2 hardware to the atlx codebase.  It is
functionally very similar to the out-of-tree 2.0.4 version that many distros
have been shipping for a few months, though it adds a fix from Atheros to fix
the problem of device resets under heavy bidirectional load.

The code needs a lot of janitorial work, and there's a lot of low-hanging fruit
for merging similar atl1 code into the shared atlx code, but I think that work
will go much faster once this is in-tree.  The driver is known to work well for
laptop and desktop use.  The only major bugs are device initialization problems
that manifest themselves immediately and obviously (the NIC doesn't work) with
certain motherboards.

Please consider this for the 2.6.28 merge window.

-- Chris

 drivers/net/Kconfig       |   17
 drivers/net/Makefile      |    1
 drivers/net/atlx/Makefile |    1
 drivers/net/atlx/atl2.c   | 3101 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/atlx/atl2.h   |  482 +++++++
 include/linux/pci_ids.h   |    1
 6 files changed, 3600 insertions(+), 3 deletions(-)

