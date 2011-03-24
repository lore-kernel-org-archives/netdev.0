From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 0/2] can: c_can: disable one shot mode and fix irq check
Date: Thu, 24 Mar 2011 13:34:31 +0100
Message-ID: <1300970073-25522-1-git-send-email-mkl@pengutronix.de>
Cc: Socketcan-core@lists.berlios.de, jan@linutronix.de,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49511 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab1CXMeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 08:34:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

can you please pick up these two bug fix patches for net-2.6/master.
I'd like to see them in 2.6.39. In the first patch we disables the one
shot mode which causes problems in the drivers tx logic. The second
patch fixes the check for a valid irq in the probe function.

regards, Marc

