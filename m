From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v2 00/10] net/fec: add dual fec support for i.MX28
Date: Tue, 4 Jan 2011 17:24:06 +0800
Message-ID: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:33786 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab1ADJXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 04:23:08 -0500
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

The 5 patches below preceding with * have changes since v1, and
the detailed change log can be found in individual patch.

 [PATCH v2 01/10] net/fec: fix MMFR_OP type in fec_enet_mdio_write
 [PATCH v2 02/10] net/fec: remove the use of "index" which is legacy
 [PATCH v2 03/10] net/fec: add mac field into platform data and consolidate fec_get_mac
 [PATCH v2 04/10] net/fec: improve pm for better suspend/resume
*[PATCH v2 05/10] net/fec: add dual fec support for mx28
*[PATCH v2 06/10] ARM: mx28: update clocks for dual fec support
 [PATCH v2 07/10] ARM: mx28: add the second fec device registration
*[PATCH v2 08/10] ARM: mxs: add ocotp read function
*[PATCH v2 09/10] ARM: mx28: read fec mac address from ocotp
*[PATCH v2 10/10] ARM: mxs: add initial pm support

Thanks for review.

Regards,
Shawn

