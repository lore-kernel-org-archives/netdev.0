From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: [PATCH 0/4] dm9000 improvements
Date: Wed, 16 Oct 2013 11:41:30 +0300
Message-ID: <1381912894-4780-1-git-send-email-nikita@compulab.co.il>
Cc: Nikita Kiryanov <nikita@compulab.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Michael Abbott <michael.abbott@diamond.ac.uk>,
	Igor Grinberg <grinberg@compulab.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:41759 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149Ab3JPImK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 04:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a collection of improvements and bug fixes for dm9000, mostly
related to its startup and resume-from-suspend sequences.

Patch "Implement full reset of DM9000 network device" was submitted to the
linux-kernel mailing list but never applied.
An archive of the submission and the following conversation can be found here:
http://lkml.indiana.edu/hypermail/linux/kernel/1205.2/02817.html

Cc: David S. Miller <davem@davemloft.net>
Cc: Jingoo Han <jg1.han@samsung.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Michael Abbott <michael.abbott@diamond.ac.uk>
Cc: Igor Grinberg <grinberg@compulab.co.il>

Michael Abbott (1):
  dm9000: Implement full reset of DM9000 network device

Nikita Kiryanov (3):
  dm9000: during init reset phy only for dm9000b
  dm9000: take phy out of reset during init
  dm9000: report the correct LPA

 drivers/net/ethernet/davicom/dm9000.c | 56 ++++++++++++++++++++++++-----------
 1 file changed, 38 insertions(+), 18 deletions(-)

-- 
1.8.1.2
