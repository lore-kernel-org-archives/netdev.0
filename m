From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net-next 0/2] mvneta xmit_more and bql support
Date: Mon, 16 Jan 2017 18:08:30 +0100
Message-ID: <1484586512-16412-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
        sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
        jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        jaz@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This is a delayed v2 of short patchset, which introduces xmit_more and BQL
to mvneta driver. The only one change was added in xmit_more support -
condition check preventing excessive descriptors concatenation before
flushing in HW.

Any comments or feedback would be welcome.

Best regards,
Marcin

Changelog:
v1 -> v2:

* Add checking condition that ensures too much descriptors are not
  concatenated before flushing in HW.

Marcin Wojtas (1):
  net: mvneta: add BQL support

Simon Guinot (1):
  net: mvneta: add xmit_more support

 drivers/net/ethernet/marvell/mvneta.c | 35 +++++++++++++++++++++++++++++------
 1 file changed, 29 insertions(+), 6 deletions(-)

-- 
1.8.3.1
