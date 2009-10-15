From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH 7/8] trivial: fix many typos s/untill/until/
Date: Thu, 15 Oct 2009 17:21:12 -0300
Message-ID: <1255638072-6236-1-git-send-email-cascardo@holoscopio.com>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-ext4@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	linux-sctp@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
To: trivial@kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/infiniband/ulp/iser/iser_verbs.c |    2 +-
 drivers/net/bonding/bond_alb.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c  |    2 +-
 drivers/scsi/bnx2i/bnx2i_iscsi.c         |    2 +-
 drivers/staging/rtl8187se/r8180.h        |    2 +-
 fs/ext4/balloc.c                         |    2 +-
 net/bluetooth/bnep/core.c                |    2 +-
 net/sctp/sm_statefuns.c                  |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index ea9e155..8579f32 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -499,7 +499,7 @@ void iser_conn_init(struct iser_conn *ib_conn)
 
  /**
  * starts the process of connecting to the target
- * sleeps untill the connection is established or rejected
+ * sleeps until the connection is established or rejected
  */
 int iser_connect(struct iser_conn   *ib_conn,
 		 struct sockaddr_in *src_addr,
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9b5936f..a1e7eb9 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -559,7 +559,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
 		}
 	}
 
-	/* do not update the entries again untill this counter is zero so that
+	/* do not update the entries again until this counter is zero so that
 	 * not to confuse the clients.
 	 */
 	bond_info->rlb_update_delay_counter = RLB_UPDATE_DELAY;
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index a084077..449886c 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -1257,7 +1257,7 @@ static int rt2800usb_init_registers(struct rt2x00_dev *rt2x00dev)
 	unsigned int i;
 
 	/*
-	 * Wait untill BBP and RF are ready.
+	 * Wait until BBP and RF are ready.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		rt2x00usb_register_read(rt2x00dev, MAC_CSR0, &reg);
diff --git a/drivers/scsi/bnx2i/bnx2i_iscsi.c b/drivers/scsi/bnx2i/bnx2i_iscsi.c
index cafb888..10110be 100644
--- a/drivers/scsi/bnx2i/bnx2i_iscsi.c
+++ b/drivers/scsi/bnx2i/bnx2i_iscsi.c
@@ -1883,7 +1883,7 @@ static void bnx2i_ep_disconnect(struct iscsi_endpoint *ep)
 
 	bnx2i_ep = ep->dd_data;
 
-	/* driver should not attempt connection cleanup untill TCP_CONNECT
+	/* driver should not attempt connection cleanup until TCP_CONNECT
 	 * completes either successfully or fails. Timeout is 9-secs, so
 	 * wait for it to complete
 	 */
diff --git a/drivers/staging/rtl8187se/r8180.h b/drivers/staging/rtl8187se/r8180.h
index 8216d7e..35ed60b 100644
--- a/drivers/staging/rtl8187se/r8180.h
+++ b/drivers/staging/rtl8187se/r8180.h
@@ -521,7 +521,7 @@ typedef struct r8180_priv
 	//u32 NumTxOkInPeriod;   //YJ,del,080828
 	u8   TxPollingTimes;
 
-	bool	bApBufOurFrame;// TRUE if AP buffer our unicast data , we will keep eAwake untill receive data or timeout.
+	bool	bApBufOurFrame;// TRUE if AP buffer our unicast data , we will keep eAwake until receive data or timeout.
 	u8	WaitBufDataBcnCount;
 	u8	WaitBufDataTimeOut;
 
diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index 1d04189..2565b8c 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -519,7 +519,7 @@ void ext4_free_blocks(handle_t *handle, struct inode *inode,
 		metadata = 1;
 
 	/* We need to make sure we don't reuse
-	 * block released untill the transaction commit.
+	 * block released until the transaction commit.
 	 * writeback mode have weak data consistency so
 	 * don't force data as metadata when freeing block
 	 * for writeback mode.
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 1bd9398..9ac0497 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -629,7 +629,7 @@ int bnep_del_connection(struct bnep_conndel_req *req)
 	s = __bnep_get_session(req->dst);
 	if (s) {
 		/* Wakeup user-space which is polling for socket errors.
-		 * This is temporary hack untill we have shutdown in L2CAP */
+		 * This is temporary hack until we have shutdown in L2CAP */
 		s->sock->sk->sk_err = EUNATCH;
 
 		/* Kill session thread */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index c8fae19..ba2f66d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3569,7 +3569,7 @@ sctp_disposition_t sctp_sf_do_asconf(const struct sctp_endpoint *ep,
 	 * To do this properly, we'll set the destination address of the chunk
 	 * and at the transmit time, will try look up the transport to use.
 	 * Since ASCONFs may be bundled, the correct transport may not be
-	 * created untill we process the entire packet, thus this workaround.
+	 * created until we process the entire packet, thus this workaround.
 	 */
 	asconf_ack->dest = chunk->source;
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(asconf_ack));
-- 
1.6.3.3

