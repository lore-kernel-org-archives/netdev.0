From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 0/9] fs enet and mdio bitbang patches
Date: Thu, 20 Sep 2007 17:00:43 -0500
Message-ID: <20070920220043.GA28769@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:47688 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbXITWBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:01:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes since previous patchset:

- Changed mdio_bitbang_ to mdiobb_, as requested.
- Separated mii bitbang conversion to generic MDIO bitbang library from the
  of_platform conversion.
- Added register read-backs to flush the writes in mdio bitbang clients.
- Fixed a couple minor issues.

Jeff, please apply for 2.6.24.

-Scott
