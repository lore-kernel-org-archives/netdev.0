From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 09/16] af_key: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:30:59 +0200
Message-ID: <1405355467-7350-10-git-send-email-fabf@skynet.be>
References: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/key/af_key.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index ba2a2f9..1847ec4 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -405,7 +405,6 @@ static int verify_address_len(const void *p)
 		 * XXX When it can, remove this -EINVAL.  -DaveM
 		 */
 		return -EINVAL;
-		break;
 	}
 
 	return 0;
@@ -536,7 +535,6 @@ pfkey_satype2proto(uint8_t satype)
 		return IPPROTO_ESP;
 	case SADB_X_SATYPE_IPCOMP:
 		return IPPROTO_COMP;
-		break;
 	default:
 		return 0;
 	}
@@ -553,7 +551,6 @@ pfkey_proto2satype(uint16_t proto)
 		return SADB_SATYPE_ESP;
 	case IPPROTO_COMP:
 		return SADB_X_SATYPE_IPCOMP;
-		break;
 	default:
 		return 0;
 	}
-- 
1.8.4.5
