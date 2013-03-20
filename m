From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: [PATCH 2/3] netlink: Remove an unused pointer in netlink_skb_parms
Date: Wed, 20 Mar 2013 14:38:39 -0700
Message-ID: <a8766c8b116b5e6fcaa932fe94f84a584554b98f.1363815201.git.luto@amacapital.net>
References: <cover.1363815201.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1363815201.git.luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
In-Reply-To: <cover.1363815201.git.luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
References: <cover.1363815201.git.luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
---
 include/linux/netlink.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index e0f746b..9ac1201 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -19,7 +19,6 @@ struct netlink_skb_parms {
 	struct scm_creds	creds;		/* Skb credentials	*/
 	__u32			portid;
 	__u32			dst_group;
-	struct sock		*ssk;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
-- 
1.8.1.4
