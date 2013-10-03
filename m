From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] ath10k: wmi: Convert use of 6 to ETH_ALEN
Date: Wed, 02 Oct 2013 20:39:11 -0700
Message-ID: <1380771551.2081.93.camel@joe-AO722>
References: <1380679480.2081.24.camel@joe-AO722>
	 <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
	 <1380696054.2081.35.camel@joe-AO722>
	 <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
	 <1380736969.2081.72.camel@joe-AO722>
	 <alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>
	 <1380758954.2081.79.camel@joe-AO722> <1380760114.2081.81.camel@joe-AO722>
	 <1380771110.2081.89.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <julia.lawall@lip6.fr>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0140.hostedemail.com ([216.40.44.140]:58995 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753360Ab3JCDjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 23:39:15 -0400
In-Reply-To: <1380771110.2081.89.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the appropriate define instead of 6.

Signed-off-by: Joe Perches <joe@perches.com>
Noticed-by: Julia Lawall <julia.lawall@lip6.fr> via spatch script

---

 drivers/net/wireless/ath/ath10k/wmi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index bee88e8..48d44e7 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -1758,7 +1758,7 @@ int ath10k_wmi_vdev_up(struct ath10k *ar, u32 vdev_id, u32 aid, const u8 *bssid)
 	cmd = (struct wmi_vdev_up_cmd *)skb->data;
 	cmd->vdev_id       = __cpu_to_le32(vdev_id);
 	cmd->vdev_assoc_id = __cpu_to_le32(aid);
-	memcpy(&cmd->vdev_bssid.addr, bssid, 6);
+	memcpy(&cmd->vdev_bssid.addr, bssid, ETH_ALEN);
 
 	ath10k_dbg(ATH10K_DBG_WMI,
 		   "wmi mgmt vdev up id 0x%x assoc id %d bssid %pM\n",
