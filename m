From: John Rigby <jrigby@FREESCALE.COM>
Subject: [PATCH 0/2][Rev4] Add MPC5121 FEC suppport
Date: Wed, 18 Jun 2008 09:15:52 -0600
Message-ID: <1213802154-28968-1-git-send-email-jrigby@freescale.com>
Cc: netdev@vger.kernel.org, John Rigby <jrigby@FREESCALE.COM>
To: Scott Wood <scottwood@FREESCALE.COM>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:64403 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbYFRPwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 11:52:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since last patch set:
    This patch no longer assmues Kumar's patch that
    removes CONFIG_PPC_CPM_NEW_BINDING stuff.  That was just
    confusing.

    No checkpatch.pl fixes.

    Addresses all comments to previous patch.

    Does not rework the Kconfig logic.  More work is need than what
    was discussed to make this work when compiling as module.

Part 1/2 changes fec_t to struct fec.

Part 2/2 adds 5121 support.


