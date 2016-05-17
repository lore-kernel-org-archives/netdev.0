From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net] tipc: fix nametable publication field
	in nl compat
Date: Tue, 17 May 2016 16:57:37 +0200
Message-ID: <1463497057-1610-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net, Richard
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The publication field of the old netlink API should contain the
publication key and not the publication reference.

Fixes: 44a8ae94fd55 (tipc: convert legacy nl name table dump to nl compat)
Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/netlink_compat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index d7d050f..4dfc5c1 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -802,7 +802,7 @@ static int tipc_nl_compat_name_table_dump(struct tipc_nl_compat_msg *msg,
 		goto out;
 
 	tipc_tlv_sprintf(msg->rep, "%-10u %s",
-			 nla_get_u32(publ[TIPC_NLA_PUBL_REF]),
+			 nla_get_u32(publ[TIPC_NLA_PUBL_KEY]),
 			 scope_str[nla_get_u32(publ[TIPC_NLA_PUBL_SCOPE])]);
 out:
 	tipc_tlv_sprintf(msg->rep, "\n");
-- 
2.1.4


------------------------------------------------------------------------------
Mobile security can be enabling, not merely restricting. Employees who
bring their own devices (BYOD) to work are irked by the imposition of MDM
restrictions. Mobile Device Manager Plus allows you to control only the
apps on BYO-devices by containerizing them, leaving personal data untouched!
https://ad.doubleclick.net/ddm/clk/304595813;131938128;j
