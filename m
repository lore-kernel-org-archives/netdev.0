From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 06/10] rfkill: Add documentation about LED triggers
Date: Mon, 22 Feb 2016 11:36:37 -0500
Message-ID: <1456159001-20307-7-git-send-email-jprvita@endlessm.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/rfkill.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 2ee6ef9..1f0c270 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -83,6 +83,8 @@ rfkill drivers that control devices that can be hard-=
blocked unless they also
 assign the poll_hw_block() callback (then the rfkill core will poll th=
e
 device). Don't do this unless you cannot get the event in any other wa=
y.
=20
+RFKill provides per-switch LED triggers, which can be used to drive LE=
Ds
+according to the switch state (LED_FULL when blocked, LED_OFF otherwis=
e).
=20
=20
 5. Userspace support
--=20
2.5.0
