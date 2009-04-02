From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] fsl_pq_mdio: Fix compile failure
Date: Thu,  2 Apr 2009 08:45:23 -0500
Message-ID: <1238679923-4370-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Segher Boessenkool <segher@kernel.crashing.org>

Add EXPORT_SYMBOL_GPL(fsl_pq_mdio_bus_name) for module builds

Signed-off-by: Segher Boessenkool <segher@kernel.crashing.org>
Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---

Dave, 

I think this got lost in a thread on the ppc list.

- k

 drivers/net/fsl_pq_mdio.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d9e1ecf..aa1eb88 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -204,6 +204,7 @@ void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
 		(unsigned long long)taddr);
 }
+EXPORT_SYMBOL_GPL(fsl_pq_mdio_bus_name);
 
 /* Scan the bus in reverse, looking for an empty spot */
 static int fsl_pq_mdio_find_free(struct mii_bus *new_bus)
-- 
1.5.6.6
