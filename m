From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH]] New: tcp_input.c:3038 missing newline character
Date: Mon, 20 Dec 2004 14:41:20 -0800
Message-ID: <20041220144120.5dfb4ee2@dxpl.pdx.osdl.net>
References: <200412202215.iBKMFSCr025060@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200412202215.iBKMFSCr025060@fire-1.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

http://bugme.osdl.org/show_bug.cgi?id=3924
The printk at net/ipv4/tcp_input.c:3038 is missing the newline (\n) character.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-12-20 14:42:23 -08:00
+++ b/net/ipv4/tcp_input.c	2004-12-20 14:42:23 -08:00
@@ -3029,7 +3029,7 @@
 							if(tp->snd_wscale > 14) {
 								if(net_ratelimit())
 									printk(KERN_INFO "tcp_parse_options: Illegal window "
-									       "scaling value %d >14 received.",
+									       "scaling value %d >14 received.\n",
 									       tp->snd_wscale);
 								tp->snd_wscale = 14;
 							}
