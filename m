From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 0/2] QE clock source improvements
Date: Mon,  3 Dec 2007 15:17:57 -0600
Message-ID: <11967166791607-git-send-email-timur@freescale.com>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:41046 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbXLCVTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 16:19:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set adds a new property to make specifying QE clock sources
easier, adds a function to help parse the property, and updates the ucc_geth
driver to take advantage of all this.

Patch #1 is an arch/powerpc patch meant for Kumar's for-2.6.25 branch.
Patch #2 is a netdev patch, so it's either for Jeff G and/or Kumar.
