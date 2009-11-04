From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 05/12] wimax: misplaced parenthesis
Date: Wed,  4 Nov 2009 13:39:41 -0800
Message-ID: <2d44f204adf503eb1774f0ab7e404031168851ea.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>

Fix misplaced parenthesis

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/tx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index fa16ccf..8c20802 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -310,7 +310,7 @@ size_t __i2400m_tx_tail_room(struct i2400m *i2400m)
 	size_t tail_room;
 	size_t tx_in;
 
-	if (unlikely(i2400m->tx_in) == 0)
+	if (unlikely(i2400m->tx_in == 0))
 		return I2400M_TX_BUF_SIZE;
 	tx_in = i2400m->tx_in % I2400M_TX_BUF_SIZE;
 	tail_room = I2400M_TX_BUF_SIZE - tx_in;
-- 
1.6.2.5
