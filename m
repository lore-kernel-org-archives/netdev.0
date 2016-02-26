From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH 0/2] phy: micrel: fix issues with interrupt on atmel boards
Date: Fri, 26 Feb 2016 19:18:21 +0100
Message-ID: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Since the phy is not polled anymore, there were issues getting a link on the
sama5d* xplained boards.

I'm not too sure about were those fixes should go and I'm wondering whether the
first one shoud be made generic.

For the second one, I found the PHY_HAS_MAGICANEG flag that is not used and I
wondering whether this is related to that kind of issue. I had a quick look at
the history and could'nt find its use.

Alexandre Belloni (2):
  phy: micrel: Ensure interrupts are reenabled on resume
  phy: micrel: Disable auto negotiation on startup

 drivers/net/phy/micrel.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

-- 
2.7.0
