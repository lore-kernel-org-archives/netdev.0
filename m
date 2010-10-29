From: Tao Ma <tao.ma@oracle.com>
Subject: [PATCH] drivers/net/igb: remove unused variable in igb_xmit_frame_ring_adv.
Date: Fri, 29 Oct 2010 10:55:49 +0800
Message-ID: <1288320949-5136-1-git-send-email-tao.ma@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tao Ma <tao.ma@oracle.com>,
	Jiri Kosina <trivial@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/igb/igb_main.c: In function =E2=80=98igb_xmit_frame_ring_ad=
v=E2=80=99:
drivers/net/igb/igb_main.c:4110: warning: unused variable =E2=80=98adap=
ter=E2=80=99

Cc: Jiri Kosina <trivial@kernel.org>
Signed-off-by: Tao Ma <tao.ma@oracle.com>
---
 drivers/net/igb/igb_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 14db09e..892d196 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4107,7 +4107,6 @@ static inline int igb_maybe_stop_tx(struct igb_ri=
ng *tx_ring, int size)
 netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 				    struct igb_ring *tx_ring)
 {
-	struct igb_adapter *adapter =3D netdev_priv(tx_ring->netdev);
 	int tso =3D 0, count;
 	u32 tx_flags =3D 0;
 	u16 first;
--=20
1.7.1.GIT
