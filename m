From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 7/7] openvswitch: Fix typo in
	documentation.
Date: Fri, 20 Jul 2012 15:26:50 -0700
Message-ID: <1342823210-3308-8-git-send-email-jesse@nicira.com>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1342823210-3308-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Leo Alterman <lalterman-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Leo Alterman <lalterman-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 Documentation/networking/openvswitch.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/openvswitch.txt b/Documentation/networking/openvswitch.txt
index b8a048b..8fa2dd1 100644
--- a/Documentation/networking/openvswitch.txt
+++ b/Documentation/networking/openvswitch.txt
@@ -118,7 +118,7 @@ essentially like this, ignoring metadata:
 Naively, to add VLAN support, it makes sense to add a new "vlan" flow
 key attribute to contain the VLAN tag, then continue to decode the
 encapsulated headers beyond the VLAN tag using the existing field
-definitions.  With this change, an TCP packet in VLAN 10 would have a
+definitions.  With this change, a TCP packet in VLAN 10 would have a
 flow key much like this:
 
     eth(...), vlan(vid=10, pcp=0), eth_type(0x0800), ip(proto=6, ...), tcp(...)
-- 
1.7.9.5
