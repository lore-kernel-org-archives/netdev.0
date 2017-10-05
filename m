From: Razvan Stefanescu <razvan.stefanescu@nxp.com>
Subject: [PATCH v3 6/6] staging: fsl-dpaa2/ethsw: Add TODO
Date: Thu, 5 Oct 2017 12:16:14 +0300
Message-ID: <1507194974-12050-7-git-send-email-razvan.stefanescu@nxp.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, arnd@arndb.de, netdev@vger.kernel.org,
 alexandru.marginean@nxp.com, linux-kernel@vger.kernel.org, agraf@suse.de,
 stuyoder@gmail.com, bogdan.purcareata@nxp.com, laurentiu.tudor@nxp.com
To: <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Add a TODO file describing what needs to be added/changed before the driver
can be moved out of staging.

Signed-off-by: Razvan Stefanescu <razvan.stefanescu@nxp.com>
---
Changelog:
 v2:
    - no changes
 v3:
    - no changes

 drivers/staging/fsl-dpaa2/ethsw/TODO | 14 ++++++++++++++
 1 file changed, 14 insertions(+)
 create mode 100644 drivers/staging/fsl-dpaa2/ethsw/TODO

diff --git a/drivers/staging/fsl-dpaa2/ethsw/TODO b/drivers/staging/fsl-dpaa2/ethsw/TODO
new file mode 100644
index 0000000..d3f12c3
--- /dev/null
+++ b/drivers/staging/fsl-dpaa2/ethsw/TODO
@@ -0,0 +1,14 @@
+* Add I/O capabilities on switch port netdevices. This will allow control
+traffic to reach the CPU.
+* Add ACL to redirect control traffic to CPU.
+* Add support for displaying learned FDB entries
+* MC firmware uprev; the DPAA2 objects used by the Ethernet Switch driver
+need to   be kept in sync with binary interface changes in MC
+* refine README file
+* cleanup
+
+NOTE: At least first three of the above are required before getting the
+DPAA2 Ethernet Switch driver out of staging. Another requirement is that
+the fsl-mc bus driver is moved to drivers/bus and dpio driver is moved to
+drivers/soc (this is required for I/O).
+
-- 
1.9.1
