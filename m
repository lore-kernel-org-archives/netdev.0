From: Marc.Obbad@smsc.com
Subject: Re: [PATCH 1/4] bridge: get rid of miscdevice include
Date: Wed, 21 Feb 2007 18:40:03 -0500
Message-ID: <OF0ED928FF.E7A477BD-ON85257289.0081F0E7-85257289.008203B0@smsc.com>
References: <20070221224255.581096490@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: bridge-bounces@lists.osdl.org, bridge@linux-foundation.org,
   David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <bridge-bounces@lists.osdl.org>
In-Reply-To: <20070221224255.581096490@linux-foundation.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

How to get those fixes for testing ?

Thanks,
-Marc.


                                                                           =
                                             =

             Stephen Hemminger                                             =
                                             =

             <shemminger@linux-foundation.org>                             =
                                             =

             Sent by:                                                      =
                                          To =

             bridge-bounces@lists.osdl.org               David Miller <dave=
m@davemloft.net>                             =

                                                                           =
                                          cc =

                                                         netdev@vger.kernel=
.org, bridge@linux-foundation.org            =

             02/21/2007 05:41 PM                                           =
                                     Subject =

                                                         [Bridge] [PATCH 1/=
4] bridge: get rid of miscdevice include     =

                                                                           =
                                             =

                                                                           =
                                             =

                                                                           =
                                             =

                                                                           =
                                             =

                                                                           =
                                             =

                                                                           =
                                             =





The bridge hasn't used miscdevice for a long long time.

Signed-off-by: StephenHemminger <shemminger@linux-foundtion.org>

---
 net/bridge/br_private.h |    1 -
 1 file changed, 1 deletion(-)

--- bridge.orig/net/bridge/br_private.h          2007-02-21 10:57:26.000000=
000 -0800
+++ bridge/net/bridge/br_private.h         2007-02-21 10:57:30.000000000 -0=
800
@@ -16,7 +16,6 @@
 #define _BR_PRIVATE_H

 #include <linux/netdevice.h>
-#include <linux/miscdevice.h>
 #include <linux/if_bridge.h>

 #define BR_HASH_BITS 8

--
Stephen Hemminger <shemminger@linux-foundation.org>

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/bridge
