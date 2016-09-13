From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH net-next 0/2] mvneta xmit_more and bql support
Date: Tue, 13 Sep 2016 09:00:04 +0200
Message-ID: <1473750006-21199-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
        sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
        jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        alior@marvell.com, simon.guinot@sequanux.org, nitroshift@yahoo.com,
        mw@semihalf.com, jaz@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This short patchset introduces two enhancements to mvneta driver
TX packets concatenation support using xmit_more mechanism and also
byte queue limit in order to decrease latency on saturated links.

Any comments or feedback would be welcome.

Best regards,
Marcin

Marcin Wojtas (1):
  net: mvneta: add BQL support

Simon Guinot (1):
  net: mvneta: add xmit_more support

 drivers/net/ethernet/marvell/mvneta.c | 33 +++++++++++++++++++++++++++------
 1 file changed, 27 insertions(+), 6 deletions(-)

-- 
1.8.3.1
