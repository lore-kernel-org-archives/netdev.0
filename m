From: Anatolij Gustschin <agust@denx.de>
Subject: [net-next-2.6 PATCH 0/3] Support for MPC512x FEC
Date: Thu, 21 Jan 2010 03:13:16 +0100
Message-ID: <1264039999-25731-1-git-send-email-agust@denx.de>
Cc: dzu@denx.de, wd@denx.de, Anatolij Gustschin <agust@denx.de>,
	<linuxppc-dev@ozlabs.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	John Rigby <jcrigby@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:40851 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663Ab0AUCNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 21:13:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches attempt to provide support for the Freescale MPC512x
FEC in the fs_enet driver. The first cleanup patch replaces printk
by dev_xxx. The second and third attemt to support MPC5121 FEC
in the FEC driver. The first version of the last two patches
was previously submitted as part of the patch series for updated
MPC5121 support. Now these are separated and also address comments
to the first version. Additionally a cleanup patch is added
to this new series. The patches are based on net-next-2.6.

[1/3] fs_enet: use dev_xxx instead of printk
[2/3] fs_enet: Add support for MPC512x to fs_enet driver
[3/3] fs_enet: Add FEC TX Alignment workaround for MPC5121

The code has been tested on the Freescale/STX "MPC5121ADS" board
(board rev. 4) with a MPC5121e Rev. 2.

Cc: <linuxppc-dev@ozlabs.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
---
