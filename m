From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] net/atm: Add some spaces for better code readability
Date: Tue, 2 May 2017 19:49:12 +0200
Message-ID: <4b0d808e-e579-771c-c3ac-a85c88c48316@users.sourceforge.net>
References: <d9577c1f-07d1-b43a-df16-8626acfb1043@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d9577c1f-07d1-b43a-df16-8626acfb1043@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 2 May 2017 19:19:14 +0200

Use space characters at some source code places according to
the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/mpoa_proc.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index 324c4f95f4bf..6a52606557f0 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -154,8 +154,8 @@ static int mpc_show(struct seq_file *m, void *v)
 		seq_printf(m, "%-16s%s%-14lu%-12u",
 			   ip_string,
 			   ingress_state_string(in_entry->entry_state),
-			   in_entry->ctrl_info.holding_time -
-			   (now.tv_sec-in_entry->tv.tv_sec),
+			   in_entry->ctrl_info.holding_time
+			   - (now.tv_sec - in_entry->tv.tv_sec),
 			   in_entry->packets_fwded);
 		if (in_entry->shortcut)
 			seq_printf(m, "   %-3d  %-3d",
@@ -173,8 +173,8 @@ static int mpc_show(struct seq_file *m, void *v)
 		seq_printf(m, "\n%-16lu%s%-14lu%-15u",
 			   (unsigned long)ntohl(eg_entry->ctrl_info.cache_id),
 			   egress_state_string(eg_entry->entry_state),
-			   (eg_entry->ctrl_info.holding_time -
-			    (now.tv_sec-eg_entry->tv.tv_sec)),
+			   eg_entry->ctrl_info.holding_time
+			   - (now.tv_sec - eg_entry->tv.tv_sec),
 			   eg_entry->packets_rcvd);
 
 		/* latest IP address */
@@ -213,7 +213,7 @@ static ssize_t proc_mpc_write(struct file *file, const char __user *buff,
 		return 0;
 
 	if (nbytes >= PAGE_SIZE)
-		nbytes = PAGE_SIZE-1;
+		nbytes = PAGE_SIZE - 1;
 
 	page = (char *)__get_free_page(GFP_KERNEL);
 	if (!page)
@@ -251,18 +251,21 @@ static int parse_qos(const char *buff)
 	memset(&qos, 0, sizeof(struct atm_qos));
 
 	if (sscanf(buff, "del %hhu.%hhu.%hhu.%hhu",
-			ip, ip+1, ip+2, ip+3) == 4) {
+		   ip, ip + 1, ip + 2, ip + 3) == 4) {
 		ipaddr = *(__be32 *)ip;
 		return atm_mpoa_delete_qos(atm_mpoa_search_qos(ipaddr));
 	}
 
 	if (sscanf(buff, "add %hhu.%hhu.%hhu.%hhu tx=%d,%d rx=tx",
-			ip, ip+1, ip+2, ip+3, &tx_pcr, &tx_sdu) == 6) {
+		   ip, ip + 1, ip + 2, ip + 3, &tx_pcr, &tx_sdu) == 6) {
 		rx_pcr = tx_pcr;
 		rx_sdu = tx_sdu;
-	} else if (sscanf(buff, "add %hhu.%hhu.%hhu.%hhu tx=%d,%d rx=%d,%d",
-		ip, ip+1, ip+2, ip+3, &tx_pcr, &tx_sdu, &rx_pcr, &rx_sdu) != 8)
-		return 0;
+	} else {
+		if (sscanf(buff, "add %hhu.%hhu.%hhu.%hhu tx=%d,%d rx=%d,%d",
+			   ip, ip + 1, ip + 2, ip + 3,
+			   &tx_pcr, &tx_sdu, &rx_pcr, &rx_sdu) != 8)
+			return 0;
+	}
 
 	ipaddr = *(__be32 *)ip;
 	qos.txtp.traffic_class = ATM_CBR;
-- 
2.12.2
