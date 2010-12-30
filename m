From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 04/15]drivers:staging:comedi:drivers:das800.c Typo change diable to disable.
Date: Thu, 30 Dec 2010 15:07:53 -0800
Message-ID: <1293750484-1161-4-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
Cc: linux-m68k@lists.linux-m68k.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The below patch fixes a typo "diable" to "disable". Please let me know if this 
is correct or not.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/staging/comedi/drivers/das800.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/comedi/drivers/das800.c b/drivers/staging/comedi/drivers/das800.c
index aecaedc..3ecae47 100644
--- a/drivers/staging/comedi/drivers/das800.c
+++ b/drivers/staging/comedi/drivers/das800.c
@@ -450,7 +450,7 @@ static irqreturn_t das800_interrupt(int irq, void *d)
 		/* otherwise, stop taking data */
 	} else {
 		spin_unlock_irqrestore(&dev->spinlock, irq_flags);
-		disable_das800(dev);	/* diable hardware triggered conversions */
+		disable_das800(dev);	/* disable hardware triggered conversions */
 		async->events |= COMEDI_CB_EOA;
 	}
 	comedi_event(dev, s);
-- 
1.6.5.2.180.gc5b3e
