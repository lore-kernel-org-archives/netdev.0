From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AF_RXRPC: AF_RXRPC depends on IPv4
Date: Mon, 14 May 2007 12:41:02 +0100
Message-ID: <20070514114102.7883.64787.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: akpm@osdl.org, avuton@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a dependency for CONFIG_AF_RXRPC on CONFIG_INET.  This fixes this error:

net/built-in.o: In function `rxrpc_get_peer':
(.text+0x42824): undefined reference to `ip_route_output_key'

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 91b3d52..e662f1d 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -4,7 +4,7 @@
 
 config AF_RXRPC
 	tristate "RxRPC session sockets"
-	depends on EXPERIMENTAL
+	depends on INET && EXPERIMENTAL
 	select KEYS
 	help
 	  Say Y or M here to include support for RxRPC session sockets (just

