From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH 0/2] [net-next] Marvell sky2 updates
Date: Wed, 04 Jul 2012 11:38:29 +0200
Message-ID: <1341394709.14972.39.camel@mlindner-lin.skd.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:34044 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932826Ab2GDJij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 05:38:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

here are a couple of sky2 driver updates. This patch series contains
support for the Optima EEE chipset and a relatively small correction to
the interrupt handler.



Mirko Lindner (2):
  This patch adds support for the Optima EEE chipset.
  Re-enable interrupts if it is not our interrupt

 drivers/net/ethernet/marvell/sky2.c |   18 ++++++++++++++++--
 drivers/net/ethernet/marvell/sky2.h |    5 +++++
 2 files changed, 21 insertions(+), 2 deletions(-)
