From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 01/12] wimax/i2400m/usb: remove unnecessary power
	management primitive in i2400m
Date: Wed,  4 Nov 2009 13:39:37 -0800
Message-ID: <663ebb4aa2fd0d19e3d1da0fed3fa3fa134a4ef0.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>
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

From: Oliver Neukum <oliver@neukum.org>

This patch removes an unneeded power management primitive.
Power management is automatically enabled as probe ends.

Signed-off-by: Oliver Neukum <oliver@neukum.org>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 7eadd11..bfa45f5 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -415,7 +415,6 @@ int i2400mu_probe(struct usb_interface *iface,
 #ifdef CONFIG_PM
 	iface->needs_remote_wakeup = 1;		/* autosuspend (15s delay) */
 	device_init_wakeup(dev, 1);
-	usb_autopm_enable(i2400mu->usb_iface);
 	usb_dev->autosuspend_delay = 15 * HZ;
 	usb_dev->autosuspend_disabled = 0;
 #endif
-- 
1.6.2.5
