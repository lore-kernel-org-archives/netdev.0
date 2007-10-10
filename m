From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 0/2] QE clock source improvements
Date: Wed, 10 Oct 2007 17:18:26 -0500
Message-ID: <1192054708946-git-send-email-timur@freescale.com>
To: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:41284 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbXJJWSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch set adds a new property to make specifying QE clock sources
easier, adds a function to help parse the property, updates some other
functions to use an enum instead of an integer, and updates the ucc_geth
driver to take advantage of all this.

