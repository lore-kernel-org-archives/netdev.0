From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/sunrpc/auth_gss/gss_krb5_crypto.c: Use normal negative
 error value return
Date: Sun, 14 Nov 2010 18:08:11 -0800
Message-ID: <1289786891.16461.102.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

And remove unnecessary double semicolon too.

No effect to code, as test is != 0.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 75ee993..9576f35 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -137,7 +137,7 @@ arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
 		ms_usage = 13;
 		break;
 	default:
-		return EINVAL;;
+		return -EINVAL;
 	}
 	salt[0] = (ms_usage >> 0) & 0xff;
 	salt[1] = (ms_usage >> 8) & 0xff;
