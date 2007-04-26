From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.22 3/5] iw_cxgb3: Initialize cpu_idx field
	in cpl_close_listserv_req message.
Date: Thu, 26 Apr 2007 15:21:15 -0500
Message-ID: <20070426202114.24234.18730.stgit@dell3.ogc.int>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com,jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070426202057.24234.56383.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Initialize cpu_idx field in cpl_close_listserv_req message.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index 2d2de9b..a990423 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1187,6 +1187,7 @@ static int listen_stop(struct iwch_liste
 	}
 	req =3D (struct cpl_close_listserv_req *) skb_put(skb, sizeof(*req));
 	req->wr.wr_hi =3D htonl(V_WR_OP(FW_WROPCODE_FORWARD));
+	req->cpu_idx =3D 0;
 	OPCODE_TID(req) =3D htonl(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ, ep->stid=
));
 	skb->priority =3D 1;
 	ep->com.tdev->send(ep->com.tdev, skb);
