From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] Add new cs89x0 driver
Date: Wed, 22 Apr 2009 09:59:30 +0200
Message-ID: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Cc: Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60477 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbZDVH7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 03:59:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While this is a very old chip it is still in use on some embedded boards.
I see myself unable to fix the in Kernel driver to bring it to driver
model support, so this patch adds a new driver designed to replace
the old one, at least for non-ISA hardware.

Sascha

