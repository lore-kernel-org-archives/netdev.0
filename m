From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AF_RXRPC: Configure crypto correctly for AF_RXRPC
Date: Wed, 28 Nov 2007 14:37:53 +0000
Message-ID: <20071128143753.15234.29444.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dhowells@redhat.com
To: mingo@elte.hu, akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932115AbXK1Oi0@vger.kernel.org>
In-Reply-To: 20071122153359.GA7268@elte.hu
References: 20071122153359.GA7268@elte.hu
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AF_RXRPC uses the crypto services, so should depend on or select CRYPTO.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index e662f1d..0d3103c 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -5,6 +5,7 @@
 config AF_RXRPC
 	tristate "RxRPC session sockets"
 	depends on INET && EXPERIMENTAL
+	select CRYPTO
 	select KEYS
 	help
 	  Say Y or M here to include support for RxRPC session sockets (just
