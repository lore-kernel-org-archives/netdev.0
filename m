From: Fabian Mewes <architekt@coding4coffee.org>
Subject: [PATCH] Documentation: networking: dsa: Update tagging protocols
Date: Fri,  4 Nov 2016 13:16:14 +0100
Message-ID: <1478261774-14265-1-git-send-email-architekt@coding4coffee.org>
Cc: "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Masanari Iida <standby24x7@gmail.com>,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        <netdev@vger.kernel.org>,
        Fabian Mewes <architekt@coding4coffee.org>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Qualcomm QCA tagging introduced in cafdc45c9 to the
list of supported protocols.

Signed-off-by: Fabian Mewes <architekt@coding4coffee.org>
---
 Documentation/networking/dsa/dsa.txt |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 6d6c07c..63912ef3 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -67,13 +67,14 @@ Note that DSA does not currently create network interfaces for the "cpu" and
 Switch tagging protocols
 ------------------------
 
-DSA currently supports 4 different tagging protocols, and a tag-less mode as
+DSA currently supports 5 different tagging protocols, and a tag-less mode as
 well. The different protocols are implemented in:
 
 net/dsa/tag_trailer.c: Marvell's 4 trailer tag mode (legacy)
 net/dsa/tag_dsa.c: Marvell's original DSA tag
 net/dsa/tag_edsa.c: Marvell's enhanced DSA tag
 net/dsa/tag_brcm.c: Broadcom's 4 bytes tag
+net/dsa/tag_qca.c: Qualcomm's 2 bytes tag
 
 The exact format of the tag protocol is vendor specific, but in general, they
 all contain something which:
-- 
1.7.10.4

