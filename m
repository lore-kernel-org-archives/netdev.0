From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/10] irda: Remove extern from function prototypes
Date: Tue, 24 Sep 2013 14:10:04 -0700
Message-ID: <294da3abaa73a0b69fd54e442b0b5bd9455b7be6.1380056108.git.joe@perches.com>
References: <cover.1380056108.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380056108.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/sir-dev.h | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/irda/sir-dev.h b/drivers/net/irda/sir-dev.h
index 6d5b1e2..f50b9c1 100644
--- a/drivers/net/irda/sir-dev.h
+++ b/drivers/net/irda/sir-dev.h
@@ -102,28 +102,29 @@ struct sir_driver {
 
 /* exported */
 
-extern int irda_register_dongle(struct dongle_driver *new);
-extern int irda_unregister_dongle(struct dongle_driver *drv);
+int irda_register_dongle(struct dongle_driver *new);
+int irda_unregister_dongle(struct dongle_driver *drv);
 
-extern struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *name);
-extern int sirdev_put_instance(struct sir_dev *self);
+struct sir_dev *sirdev_get_instance(const struct sir_driver *drv,
+				    const char *name);
+int sirdev_put_instance(struct sir_dev *self);
 
-extern int sirdev_set_dongle(struct sir_dev *dev, IRDA_DONGLE type);
-extern void sirdev_write_complete(struct sir_dev *dev);
-extern int sirdev_receive(struct sir_dev *dev, const unsigned char *cp, size_t count);
+int sirdev_set_dongle(struct sir_dev *dev, IRDA_DONGLE type);
+void sirdev_write_complete(struct sir_dev *dev);
+int sirdev_receive(struct sir_dev *dev, const unsigned char *cp, size_t count);
 
 /* low level helpers for SIR device/dongle setup */
-extern int sirdev_raw_write(struct sir_dev *dev, const char *buf, int len);
-extern int sirdev_raw_read(struct sir_dev *dev, char *buf, int len);
-extern int sirdev_set_dtr_rts(struct sir_dev *dev, int dtr, int rts);
+int sirdev_raw_write(struct sir_dev *dev, const char *buf, int len);
+int sirdev_raw_read(struct sir_dev *dev, char *buf, int len);
+int sirdev_set_dtr_rts(struct sir_dev *dev, int dtr, int rts);
 
 /* not exported */
 
-extern int sirdev_get_dongle(struct sir_dev *self, IRDA_DONGLE type);
-extern int sirdev_put_dongle(struct sir_dev *self);
+int sirdev_get_dongle(struct sir_dev *self, IRDA_DONGLE type);
+int sirdev_put_dongle(struct sir_dev *self);
 
-extern void sirdev_enable_rx(struct sir_dev *dev);
-extern int sirdev_schedule_request(struct sir_dev *dev, int state, unsigned param);
+void sirdev_enable_rx(struct sir_dev *dev);
+int sirdev_schedule_request(struct sir_dev *dev, int state, unsigned param);
 
 /* inline helpers */
 
-- 
1.8.1.2.459.gbcd45b4.dirty
