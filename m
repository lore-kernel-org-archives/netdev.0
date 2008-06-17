From: John Rigby <jrigby@freescale.com>
Subject: [PATCH 0/2] Add MPC5121 FEC suppport
Date: Tue, 17 Jun 2008 17:03:12 -0600
Message-ID: <1213743794-3537-1-git-send-email-jrigby@freescale.com>
Cc: netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:39381 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761100AbYFQXDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:03:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note:  This patch series assumes Kumar's Remove
!CONFIG_PPC_CPM_NEW_BINDING patch has been applied. 
http://patchwork.ozlabs.org/linuxppc/patch?q=kumar&id=18939

Addresses all comments to previous patch.
Split the patch into two parts:

Part 1 fixes all problems reported by checkpatch.pl
and changes instances of fec_t to struct fec.

Part 2 addes 5121 support.  And cleans up the Kconfig
logic based on input from Scott Wood and Sam Ravnborg.


