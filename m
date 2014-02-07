From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 18/26] drivers: isdn: Mark functions as static in layer2.c
Date: Fri, 7 Feb 2014 18:11:28 +0530
Message-ID: <ebc5933198231d48244fbb1975f43b416f6128e8.1390408518.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark functions as static in mISDN/layer2.c because they are not used
outside this file.

This eliminates following warnings in mISDN/layer2.c:
drivers/isdn/mISDN/layer2.c:120:1: warning: no previous prototype for =E2=
=80=98l2headersize=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:127:1: warning: no previous prototype for =E2=
=80=98l2addrsize=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:379:1: warning: no previous prototype for =E2=
=80=98cansend=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:391:1: warning: no previous prototype for =E2=
=80=98clear_exception=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:439:1: warning: no previous prototype for =E2=
=80=98IsUI=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:445:1: warning: no previous prototype for =E2=
=80=98IsUA=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:451:1: warning: no previous prototype for =E2=
=80=98IsDM=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:457:1: warning: no previous prototype for =E2=
=80=98IsDISC=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:463:1: warning: no previous prototype for =E2=
=80=98IsRR=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:472:1: warning: no previous prototype for =E2=
=80=98IsSFrame=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:482:1: warning: no previous prototype for =E2=
=80=98IsSABME=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:490:1: warning: no previous prototype for =E2=
=80=98IsREJ=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:497:1: warning: no previous prototype for =E2=
=80=98IsFRMR=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:503:1: warning: no previous prototype for =E2=
=80=98IsRNR=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:649:1: warning: no previous prototype for =E2=
=80=98get_PollFlag=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:655:1: warning: no previous prototype for =E2=
=80=98get_PollFlagFree=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:665:1: warning: no previous prototype for =E2=
=80=98start_t200=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:672:1: warning: no previous prototype for '=
restart_t200=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:679:1: warning: no previous prototype for =E2=
=80=98stop_t200=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:686:1: warning: no previous prototype for =E2=
=80=98st5_dl_release_l2l3=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:698:1: warning: no previous prototype for =E2=
=80=98lapb_dl_release_l2l3=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:1133:1: warning: no previous prototype for =
=E2=80=98enquiry_response=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/mISDN/layer2.c:1143:1: warning: no previous prototype for =
=E2=80=98transmit_enquiry=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/mISDN/layer2.c |   53 ++++++++++++++++++-----------------=
--------
 1 file changed, 22 insertions(+), 31 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 949cabb..b59e5ed 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -116,14 +116,14 @@ l2m_debug(struct FsmInst *fi, char *fmt, ...)
 	va_end(va);
 }
=20
-inline u_int
+static inline u_int
 l2headersize(struct layer2 *l2, int ui)
 {
 	return ((test_bit(FLG_MOD128, &l2->flag) && (!ui)) ? 2 : 1) +
 		(test_bit(FLG_LAPD, &l2->flag) ? 2 : 1);
 }
=20
-inline u_int
+static inline u_int
 l2addrsize(struct layer2 *l2)
 {
 	return test_bit(FLG_LAPD, &l2->flag) ? 2 : 1;
@@ -375,7 +375,7 @@ ReleaseWin(struct layer2 *l2)
 		       "isdnl2 freed %d skbuffs in release\n", cnt);
 }
=20
-inline unsigned int
+static inline unsigned int
 cansend(struct layer2 *l2)
 {
 	unsigned int p1;
@@ -387,7 +387,7 @@ cansend(struct layer2 *l2)
 	return (p1 < l2->window) && !test_bit(FLG_PEER_BUSY, &l2->flag);
 }
=20
-inline void
+static inline void
 clear_exception(struct layer2 *l2)
 {
 	test_and_clear_bit(FLG_ACK_PEND, &l2->flag);
@@ -435,40 +435,31 @@ enqueue_ui(struct layer2 *l2, struct sk_buff *skb=
)
 		dev_kfree_skb(skb);
 }
=20
-inline int
+static inline int
 IsUI(u_char *data)
 {
 	return (data[0] & 0xef) =3D=3D UI;
 }
=20
-inline int
+static inline int
 IsUA(u_char *data)
 {
 	return (data[0] & 0xef) =3D=3D UA;
 }
=20
-inline int
+static inline int
 IsDM(u_char *data)
 {
 	return (data[0] & 0xef) =3D=3D DM;
 }
=20
-inline int
+static inline int
 IsDISC(u_char *data)
 {
 	return (data[0] & 0xef) =3D=3D DISC;
 }
=20
-inline int
-IsRR(u_char *data, struct layer2 *l2)
-{
-	if (test_bit(FLG_MOD128, &l2->flag))
-		return data[0] =3D=3D RR;
-	else
-		return (data[0] & 0xf) =3D=3D 1;
-}
-
-inline int
+static inline int
 IsSFrame(u_char *data, struct layer2 *l2)
 {
 	register u_char d =3D *data;
@@ -478,7 +469,7 @@ IsSFrame(u_char *data, struct layer2 *l2)
 	return ((d & 0xf3) =3D=3D 1) && ((d & 0x0c) !=3D 0x0c);
 }
=20
-inline int
+static inline int
 IsSABME(u_char *data, struct layer2 *l2)
 {
 	u_char d =3D data[0] & ~0x10;
@@ -486,20 +477,20 @@ IsSABME(u_char *data, struct layer2 *l2)
 	return test_bit(FLG_MOD128, &l2->flag) ? d =3D=3D SABME : d =3D=3D SA=
BM;
 }
=20
-inline int
+static inline int
 IsREJ(u_char *data, struct layer2 *l2)
 {
 	return test_bit(FLG_MOD128, &l2->flag) ?
 		data[0] =3D=3D REJ : (data[0] & 0xf) =3D=3D REJ;
 }
=20
-inline int
+static inline int
 IsFRMR(u_char *data)
 {
 	return (data[0] & 0xef) =3D=3D FRMR;
 }
=20
-inline int
+static inline int
 IsRNR(u_char *data, struct layer2 *l2)
 {
 	return test_bit(FLG_MOD128, &l2->flag) ?
@@ -645,13 +636,13 @@ send_uframe(struct layer2 *l2, struct sk_buff *sk=
b, u_char cmd, u_char cr)
 }
=20
=20
-inline u_char
+static inline u_char
 get_PollFlag(struct layer2 *l2, struct sk_buff *skb)
 {
 	return skb->data[l2addrsize(l2)] & 0x10;
 }
=20
-inline u_char
+static inline u_char
 get_PollFlagFree(struct layer2 *l2, struct sk_buff *skb)
 {
 	u_char PF;
@@ -661,28 +652,28 @@ get_PollFlagFree(struct layer2 *l2, struct sk_buf=
f *skb)
 	return PF;
 }
=20
-inline void
+static inline void
 start_t200(struct layer2 *l2, int i)
 {
 	mISDN_FsmAddTimer(&l2->t200, l2->T200, EV_L2_T200, NULL, i);
 	test_and_set_bit(FLG_T200_RUN, &l2->flag);
 }
=20
-inline void
+static inline void
 restart_t200(struct layer2 *l2, int i)
 {
 	mISDN_FsmRestartTimer(&l2->t200, l2->T200, EV_L2_T200, NULL, i);
 	test_and_set_bit(FLG_T200_RUN, &l2->flag);
 }
=20
-inline void
+static inline void
 stop_t200(struct layer2 *l2, int i)
 {
 	if (test_and_clear_bit(FLG_T200_RUN, &l2->flag))
 		mISDN_FsmDelTimer(&l2->t200, i);
 }
=20
-inline void
+static inline void
 st5_dl_release_l2l3(struct layer2 *l2)
 {
 	int pr;
@@ -694,7 +685,7 @@ st5_dl_release_l2l3(struct layer2 *l2)
 	l2up_create(l2, pr, 0, NULL);
 }
=20
-inline void
+static inline void
 lapb_dl_release_l2l3(struct layer2 *l2, int f)
 {
 	if (test_bit(FLG_LAPB, &l2->flag))
@@ -1129,7 +1120,7 @@ enquiry_cr(struct layer2 *l2, u_char typ, u_char =
cr, u_char pf)
 	enqueue_super(l2, skb);
 }
=20
-inline void
+static inline void
 enquiry_response(struct layer2 *l2)
 {
 	if (test_bit(FLG_OWN_BUSY, &l2->flag))
@@ -1139,7 +1130,7 @@ enquiry_response(struct layer2 *l2)
 	test_and_clear_bit(FLG_ACK_PEND, &l2->flag);
 }
=20
-inline void
+static inline void
 transmit_enquiry(struct layer2 *l2)
 {
 	if (test_bit(FLG_OWN_BUSY, &l2->flag))
--=20
1.7.9.5
