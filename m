From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 4/9] fsl/fman: enlarge FIFO to allow for the 5th port
Date: Tue, 21 Feb 2017 13:52:49 +0200
Message-ID: <1487677974-13678-5-git-send-email-madalin.bucur@nxp.com>
References: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <camelia.groza@nxp.com>, <linuxppc-dev@lists.ozlabs.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index d755930..4aefe24 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -1212,7 +1212,7 @@ static int fill_soc_specific_params(struct fman_state_struct *state)
 		state->max_num_of_open_dmas	= 32;
 		state->fm_port_num_of_cg	= 256;
 		state->num_of_rx_ports	= 6;
-		state->total_fifo_size	= 122 * 1024;
+		state->total_fifo_size	= 136 * 1024;
 		break;
 
 	case 2:
-- 
2.1.0
