From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [NET] Update documentation of skb_linearize
Date: Fri, 10 Nov 2006 23:03:55 +0100
Message-ID: <20061110220355.GC9453@electric-eye.fr.zoreil.com>
References: <20061110191745.GA13783@codepoet.org> <20061110115444.07f58e40@freekitty> <20061110205327.19468.qmail@farnsworth.org> <20061110210343.GA9453@electric-eye.fr.zoreil.com> <20061110130715.5e99ce9f@freekitty> <20061110213043.GB9453@electric-eye.fr.zoreil.com> <20061110133555.7400e555@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:24789 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S966122AbWKJWEm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:04:42 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061110133555.7400e555@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The data is not released.

drivers/net/mv643xx_eth.c apart, each current caller issues
kfree_skb() when required.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85577a4..380e344 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1235,7 +1235,7 @@ static inline int __skb_linearize(struct
  *	@skb: buffer to linarize
  *
  *	If there is no free memory -ENOMEM is returned, otherwise zero
- *	is returned and the old skb data released.
+ *	is returned.
  */
 static inline int skb_linearize(struct sk_buff *skb)
 {
@@ -1247,7 +1247,7 @@ static inline int skb_linearize(struct s
  *	@skb: buffer to process
  *
  *	If there is no free memory -ENOMEM is returned, otherwise zero
- *	is returned and the old skb data released.
+ *	is returned.
  */
 static inline int skb_linearize_cow(struct sk_buff *skb)
 {
