From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/7] rxrpc: Remove some excess whitespace
Date: Tue, 29 Aug 2017 13:27:21 +0100
Message-ID: <150400964121.21371.7913121279387534846.stgit@warthog.procyon.org.uk>
References: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove indentation from some blank lines.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index a2ad4482376f..31e97f714ca9 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -591,13 +591,13 @@ static int rxrpc_getsockopt(struct socket *sock, int level, int optname,
 			    char __user *optval, int __user *_optlen)
 {
 	int optlen;
-	
+
 	if (level != SOL_RXRPC)
 		return -EOPNOTSUPP;
 
 	if (get_user(optlen, _optlen))
 		return -EFAULT;
-	
+
 	switch (optname) {
 	case RXRPC_SUPPORTED_CMSG:
 		if (optlen < sizeof(int))
@@ -606,7 +606,7 @@ static int rxrpc_getsockopt(struct socket *sock, int level, int optname,
 		    put_user(sizeof(int), _optlen))
 			return -EFAULT;
 		return 0;
-		
+
 	default:
 		return -EOPNOTSUPP;
 	}
