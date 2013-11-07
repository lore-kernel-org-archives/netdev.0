From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCHv2 next-next 3/3] net: skbuff - kernel-doc fixes
Date: Thu,  7 Nov 2013 14:18:26 +0100
Message-ID: <1383830306-16697-4-git-send-email-mathias.krause@secunet.com>
References: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Mathias Krause <mathias.krause@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55218 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322Ab3KGNSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 08:18:39 -0500
In-Reply-To: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use "@" to refer to parameters in the kernel-doc description. According
to Documentation/kernel-doc-nano-HOWTO.txt "&" shall be used to refer to
structures only.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 include/linux/skbuff.h |    2 +-
 net/core/skbuff.c      |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 491dd6c..036ec7d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1357,7 +1357,7 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
  * @size: the length of the data
  *
  * As per __skb_fill_page_desc() -- initialises the @i'th fragment of
- * @skb to point to &size bytes at offset @off within @page. In
+ * @skb to point to @size bytes at offset @off within @page. In
  * addition updates @skb such that @i is the last fragment.
  *
  * Does not take any additional reference on the fragment.
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2fbea08..8c5197f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1051,8 +1051,8 @@ EXPORT_SYMBOL(__pskb_copy);
  *	@ntail: room to add at tail
  *	@gfp_mask: allocation priority
  *
- *	Expands (or creates identical copy, if &nhead and &ntail are zero)
- *	header of skb. &sk_buff itself is not changed. &sk_buff MUST have
+ *	Expands (or creates identical copy, if @nhead and @ntail are zero)
+ *	header of @skb. &sk_buff itself is not changed. &sk_buff MUST have
  *	reference count of 1. Returns zero in the case of success or error,
  *	if expansion failed. In the last case, &sk_buff is not changed.
  *
@@ -2563,14 +2563,14 @@ EXPORT_SYMBOL(skb_prepare_seq_read);
  * @data: destination pointer for data to be returned
  * @st: state variable
  *
- * Reads a block of skb data at &consumed relative to the
+ * Reads a block of skb data at @consumed relative to the
  * lower offset specified to skb_prepare_seq_read(). Assigns
- * the head of the data block to &data and returns the length
+ * the head of the data block to @data and returns the length
  * of the block or 0 if the end of the skb data or the upper
  * offset has been reached.
  *
  * The caller is not required to consume all of the data
- * returned, i.e. &consumed is typically set to the number
+ * returned, i.e. @consumed is typically set to the number
  * of bytes already consumed and the next call to
  * skb_seq_read() will return the remaining part of the block.
  *
-- 
1.7.2.3
