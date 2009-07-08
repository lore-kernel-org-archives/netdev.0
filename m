From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH 24/44] includecheck fix: drivers/net, axnet_cs.c
Date: Wed, 08 Jul 2009 20:53:53 +0530
Message-ID: <1247066633.4382.70.camel@ht.satnam>
References: <1247063308.4382.12.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
	linux-pcmcia@lists.infradead.org, Sam Ravnborg <sam@ravnborg.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <1247063308.4382.12.camel@ht.satnam>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
	<mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: linux-pcmcia-bounces@lists.infradead.org
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


fix the following 'make includecheck' warning:

  drivers/net/pcmcia/axnet_cs.c: linux/etherdevice.h is included more than once.

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/pcmcia/axnet_cs.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 0e38d80..5a17117 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -893,8 +893,6 @@ static const char version_8390[] = KERN_INFO \
 #include <linux/in.h>
 #include <linux/interrupt.h>
 
-#include <linux/etherdevice.h>
-
 #define BUG_83C690
 
 /* These are the operational function interfaces to board-specific
-- 
1.6.0.6
