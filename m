From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH] RFKill airplane mode LED trigger
Date: Sat, 26 Dec 2015 10:05:02 -0500
Message-ID: <1451142303-1872-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a LED trigger to drive the airplane mode LED present in=
 some
modern laptops. It will be used by the asus-wireless platform driver, w=
hich is
currently under review on platform-driver-x86@vger.kernel.org (the idea=
 was
mainly approved, but I'm addressing some comments by the maintainers).

Jo=C3=A3o Paulo Rechi Vita (1):
  net/rfkill: Create "airplane mode" LED trigger

 net/rfkill/core.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

--=20
2.5.0
