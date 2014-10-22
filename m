From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/2] DSA tagging mismatches
Date: Thu, 23 Oct 2014 01:35:16 +0200
Message-ID: <1414020918-20903-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42321 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932666AbaJVXgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 19:36:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second patch is a fix, which should be applied to -rc. It is
possible to get a DSA configuration which does not work. The patch
stops this happening.

The first patch detects this situation, and errors out the probe of
DSA, making it more obvious something is wrong. It is not required to
apply it -rc.

Andrew Lunn (2):
  net: dsa: Error out on tagging protocol mismatches
  dsa: mv88e6171: Fix tagging protocol/Kconfig

 drivers/net/dsa/mv88e6171.c | 2 +-
 net/dsa/dsa.c               | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

-- 
2.1.1
