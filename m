From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH] gigaset: don't enable any debugging output by default
Date: Sat,  5 Dec 2009 18:52:19 +0100 (CET)
Message-ID: <20091205175219.4298A400D9@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        isdn4linux-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org, Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Karsten Keil <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

When built with debugging support, the Gigaset driver enabled some
debugging messages by default. Change the default to "all off".

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
---

Please merge for 2.6.33 so I can in good conscience encourage people to
build the driver with CONFIG_GIGASET_DEBUG=y. ;-)

Thanks, Tilman

 drivers/isdn/gigaset/common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index c438cfc..a0b85d1 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -29,7 +29,7 @@
 #endif
 
 /* Module parameters */
-int gigaset_debuglevel = DEBUG_DEFAULT;
+int gigaset_debuglevel;
 EXPORT_SYMBOL_GPL(gigaset_debuglevel);
 module_param_named(debug, gigaset_debuglevel, int, S_IRUGO|S_IWUSR);
 MODULE_PARM_DESC(debug, "debug level");
-- 
1.6.5.3.298.g39add
