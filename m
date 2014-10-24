From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 0/2] DSA tagging mismatches
Date: Fri, 24 Oct 2014 23:44:03 +0200
Message-ID: <1414187045-8326-1-git-send-email-andrew@lunn.ch>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43492 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbaJXVpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2014 17:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second patch is a fix, which should be applied to -rc. It is
possible to get a DSA configuration which does not work. The patch
stops this happening.

The first patch detects this situation, and errors out the probe of
DSA, making it more obvious something is wrong. It is not required to
apply it -rc.


v2 fixes the use case pointed out by Florian, that a switch driver
may use DSA_TAG_PROTO_NONE which the patch did not correctly handle.

Andrew Lunn (2):
  net: dsa: Error out on tagging protocol mismatches
  dsa: mv88e6171: Fix tagging protocol/Kconfig

 drivers/net/dsa/mv88e6171.c | 2 +-
 net/dsa/dsa.c               | 5 ++++-
 2 files changed, 5 insertions(+), 2 deletions(-)

-- 
2.1.1
