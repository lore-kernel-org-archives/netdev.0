From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] bad initializer in ipv6 netfilter.
Date: Mon, 12 Jul 2004 15:03:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712150341.44a84ff6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, coreteam@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Missing equal sign in C99 initializer.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
--- a/net/ipv6/netfilter/ip6table_raw.c	2004-07-12 14:46:39 -07:00
+++ b/net/ipv6/netfilter/ip6table_raw.c	2004-07-12 14:46:39 -07:00
@@ -74,7 +74,7 @@
 		{
 			.entry = {
 				.target_offset = sizeof(struct ip6t_entry),
-				.next_offset sizeof(struct ip6t_standard),
+				.next_offset = sizeof(struct ip6t_standard),
 			},
 			.target = {
 				.target = {
