From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 0/2] QE clock source improvements
Date: Wed, 10 Oct 2007 17:37:06 -0500
Message-ID: <11920558283326-git-send-email-timur@freescale.com>
To: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:42994 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691AbXJJWhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:37:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Replaces all previous versions of this patch)

This patch set adds a new property to make specifying QE clock sources
easier, adds a function to help parse the property, updates some other
functions to use an enum instead of an integer, and updates the ucc_geth
driver to take advantage of all this.

