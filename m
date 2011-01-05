From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v3 00/10] net/fec: add dual fec support for i.MX28
Date: Wed, 5 Jan 2011 22:07:27 +0800
Message-ID: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:24573
	"EHLO AM1EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751026Ab1AEOGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 09:06:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is to add dual fec support for mx28, which is
a mxs-based soc. Some code changes related to the following commits
are also made in this patch set for some reasons.

 e6b043d512fa8d9a3801bf5d72bfa3b8fc3b3cc8
 netdev/fec.c: add phylib supporting to enable carrier detection (v2)

 e3fe8558c7fc182972c3d947d88744482111f304
 net/fec: fix pm to survive to suspend/resume

It's been tested on mx28 evk and mx51 babbage. For mx28, it has
to work against the tree

 git://git.pengutronix.de/git/imx/linux-2.6.git imx-for-2.6.38

plus patch

 [PATCH v4] ARM: mxs: Change duart device to use amba-pl011

Changes for v3:
 - Move v2 changes on patch #5 to #3
 - Use device name to detect the running of mx28 fec controller
   naming ENET-MAC

The 3 patches below preceding with * have changes since v2, and
the detailed change log can be found in individual patch.

 [PATCH v3 01/10] net/fec: fix MMFR_OP type in fec_enet_mdio_write
 [PATCH v3 02/10] net/fec: remove the use of "index" which is legacy
*[PATCH v3 03/10] net/fec: add mac field into platform data and consolidate fec_get_mac
 [PATCH v3 04/10] net/fec: improve pm for better suspend/resume
*[PATCH v3 05/10] net/fec: add dual fec support for mx28
*[PATCH v3 06/10] ARM: mx28: update clock and device name for dual fec support
 [PATCH v3 07/10] ARM: mx28: add the second fec device registration
 [PATCH v3 08/10] ARM: mxs: add ocotp read function
 [PATCH v3 09/10] ARM: mx28: read fec mac address from ocotp
 [PATCH v3 10/10] ARM: mxs: add initial pm support

Thanks for the review.

Regards,
Shawn

