From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH v2 9/9] drivers: net: Mark function xenvif_count_frag_slots()
 as static in netback.c
Date: Sat, 14 Dec 2013 18:02:16 +0530
Message-ID: <609db9fcc843525f9ca2f18673744cad2fb9fb8c.1386911124.git.rashika.kheria@gmail.com>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch marks the function xenvif_count_frag_slots() in netback.c as
static because they are not used outside this file.

Thus, it also removes the following warning in xen-netback/netback.c:
drivers/net/xen-netback/netback.c:218:14: warning: no previous prototyp=
e for =E2=80=98xenvif_count_frag_slots=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---

This revision fixes the following issues of the previous revision:
Change commit message subject

 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 64f0e0d..9e4f399 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -215,7 +215,7 @@ struct xenvif_count_slot_state {
 	bool head;
 };
=20
-unsigned int xenvif_count_frag_slots(struct xenvif *vif,
+static unsigned int xenvif_count_frag_slots(struct xenvif *vif,
 				     unsigned long offset, unsigned long size,
 				     struct xenvif_count_slot_state *state)
 {
--=20
1.7.9.5
