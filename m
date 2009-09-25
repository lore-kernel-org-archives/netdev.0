From: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Subject: [PATCH v2 2/2 scsi-post-merge] cxgb3i: support of private MAC address in iSCSI
Date: Fri, 25 Sep 2009 15:25:36 -0700
Message-ID: <200909252225.n8PMPaa4031752@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


[PATCH v2 2/2 scsi-post-merge] cxgb3i: private MAC address for iSCSI

From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
        
This patch updated the use of private MAC address per port in iscsi.

This patch is generated against scsi-post-merge.
             
Signed-off-by: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
--- 
 drivers/scsi/cxgb3i/cxgb3i_offload.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/scsi/cxgb3i/cxgb3i_offload.h b/drivers/scsi/cxgb3i/cxgb3i_offload.h
index 6a1d86b..f585ece 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_offload.h
+++ b/drivers/scsi/cxgb3i/cxgb3i_offload.h
@@ -234,9 +234,9 @@ struct sge_opaque_hdr {
  * get and set private ip for iscsi traffic
  */
 #define cxgb3i_get_private_ipv4addr(ndev) \
-	(((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr)
+	(((struct port_info *)(netdev_priv(ndev)))->iscsic.ipv4_addr)
 #define cxgb3i_set_private_ipv4addr(ndev, addr) \
-	(((struct port_info *)(netdev_priv(ndev)))->iscsi_ipv4addr) = addr
+	(((struct port_info *)(netdev_priv(ndev)))->iscsic.ipv4_addr) = addr
 
 /* max. connections per adapter */
 #define CXGB3I_MAX_CONN		16384
