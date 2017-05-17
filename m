From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/6] net: phy: marvell: Checkpatch cleanup
Date: Wed, 17 May 2017 03:25:58 +0200
Message-ID: <1494984364-19496-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32812 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751045AbdEQB2l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 21:28:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will be contributing a few new features to the Marvell PHY driver
soon. Start by making the code mostly checkpatch clean. There should
not be any functional changes. Just comments set into the correct
format, missing blank lines, turn some comparisons around, and
refactoring to reduce indentation depth.

There is still one camel in the code, but it actually makes sense, so
leave it in piece.


Andrew Lunn (6):
  net: phy: Marvell: checkpatch - Comments
  net: phy: marvell: Checkpatch - Missing or extra blank lines
  net: phy: marvell: Checkpatch - assignments and comparisons
  net: phy: marvell: Refactor some bigger functions
  net: phy: marvell: Add helpers to get/set page
  net: phy: marvell: checkpatch - Fix remaining long lines

 drivers/net/phy/marvell.c | 636 +++++++++++++++++++++++++---------------------
 1 file changed, 352 insertions(+), 284 deletions(-)

-- 
2.11.0
