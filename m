From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH v2 0/5] net: macb updates
Date: Tue, 10 Dec 2013 16:07:18 -0800
Message-ID: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48833 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab3LKAHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 19:07:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd really like to have Ethernet working for Zynq, so I want to at leas=
t
revive this discussion regarding this patchset. And the first four
patches should not even be too controversial.
I didn't change anything compared to my original RFC submission, except
for a typo in one of the commit messages.
Handling the tx_clk as optional clock input seems a little bit weird,
but it works on my Zynq platform and should be compatible with other
users of macb and their DT descriptions.

	Thanks,
	S=C3=B6ren

Soren Brinkmann (5):
  net: macb: Migrate to dev_pm_ops
  net: macb: Migrate to devm clock interface
  net: macb: Use devm_ioremap()
  net: macb: Use devm_request_irq()
  net: macb: Adjust tx_clk when link speed changes

 drivers/net/ethernet/cadence/macb.c | 126 +++++++++++++++++++++++++++-=
--------
 drivers/net/ethernet/cadence/macb.h |   1 +
 2 files changed, 98 insertions(+), 29 deletions(-)

--=20
1.8.5.1
