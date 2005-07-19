From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5/8][ATM]: [firestream] fix the sparse warning "implicit cast to nocast type"
Date: Tue, 19 Jul 2005 16:45:43 -0400
Message-ID: <200507192045.j6JKjgHO027216@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: [firestream] fix the sparse warning "implicit cast to nocast type"

Signed-off-by: Victor Fusco <victor@cetuc.puc-rio.br>
Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit 6e59c9c1673a7b31f00cc8dd79f1e11abf91be9a
tree 962d15261cc88a8b094461689bcc122896508333
parent 9c893a8cd5716416ee719a57e04e01aeb2c68bd3
author chas williams <chas@relax.(none)> Tue, 19 Jul 2005 15:07:01 -0400
committer chas williams <chas@relax.(none)> Tue, 19 Jul 2005 15:07:01 -0400

 drivers/atm/firestream.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1374,7 +1374,8 @@ static void reset_chip (struct fs_dev *d
 	}
 }
 
-static void __devinit *aligned_kmalloc (int size, int flags, int alignment)
+static void __devinit *aligned_kmalloc (int size, unsigned int __nocast flags,
+					int alignment)
 {
 	void  *t;
 
@@ -1464,7 +1465,8 @@ static inline int nr_buffers_in_freepool
    does. I've seen "receive abort: no buffers" and things started
    working again after that...  -- REW */
 
-static void top_off_fp (struct fs_dev *dev, struct freepool *fp, int gfp_flags)
+static void top_off_fp (struct fs_dev *dev, struct freepool *fp,
+			unsigned int __nocast gfp_flags)
 {
 	struct FS_BPENTRY *qe, *ne;
 	struct sk_buff *skb;
