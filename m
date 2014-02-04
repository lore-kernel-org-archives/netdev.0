From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] openvswitch: flow_netlink: Use pr_fmt to
 OVS_NLERR output
Date: Mon, 03 Feb 2014 17:18:21 -0800
Message-ID: <1391476701.2538.9.camel@joe-AO722>
References: <1391389686-34303-1-git-send-email-jesse@nicira.com>
	<1391389686-34303-6-git-send-email-jesse@nicira.com>
	<1391410526.2784.9.camel@joe-AO722>
	<CAEP_g=_vvSPLt76VUE66XHJtgCW_05acn-r77PfkJFWBkT0S2A@mail.gmail.com>
	<1391465288.2538.1.camel@joe-AO722>
	<CAEP_g=83oVtSTMmLB7O8g=a3e5ghjHp7Bgs-f4nvgqCvWqE5VQ@mail.gmail.com>
	<1391476006.2538.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org" <dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391476006.2538.5.camel@joe-AO722>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add "openvswitch: " prefix to OVS_NLERR output
to match the other OVS_NLERR output of datapath.c

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/openvswitch/flow_netlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 4d000ac..c4e1326 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -16,6 +16,8 @@
  * 02110-1301, USA
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "flow.h"
 #include "datapath.h"
 #include <linux/uaccess.h>
