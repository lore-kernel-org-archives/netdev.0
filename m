From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [IPSEC] IPV6: Fix to add tunnel mode SA correctly.
Date: Mon, 22 Oct 2007 15:09:34 +0900
Message-ID: <11930333741879-git-send-email-nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:47266 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbXJVGcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:32:17 -0400
In-Reply-To: <20071017.213523.58458049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/ah6.c  |    1 +
 net/ipv6/esp6.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 67cd066..66a9139 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -483,6 +483,7 @@ static int ah6_init_state(struct xfrm_state *x)
 		break;
 	case XFRM_MODE_TUNNEL:
 		x->props.header_len += sizeof(struct ipv6hdr);
+		break;
 	default:
 		goto error;
 	}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index b071543..72a6598 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -360,6 +360,7 @@ static int esp6_init_state(struct xfrm_state *x)
 		break;
 	case XFRM_MODE_TUNNEL:
 		x->props.header_len += sizeof(struct ipv6hdr);
+		break;
 	default:
 		goto error;
 	}
-- 
1.4.4.2

