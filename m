From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: alg_key_len should be unsigned to avoid integer divides
Date: Sat, 12 Jan 2008 21:32:23 -0800 (PST)
Message-ID: <20080112.213223.82837118.davem@davemloft.net>
References: <4788F8FC.3010001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56240
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751189AbYAMFcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:32:24 -0500
In-Reply-To: <4788F8FC.3010001@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 12 Jan 2008 18:29:32 +0100

> alg_key_len is currently defined as 'signed int'. This unfortunatly leads
> to integer divides in several paths.
> 
> Converting it to unsigned is safe and saves 208 bytes of text on i386.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.

I realigned the struct members in a follow-on changeset.

commit 7305e737926be49e09718df53f4285bf69cc3755
Author: David S. Miller <davem@davemloft.net>
Date:   Sat Jan 12 21:31:29 2008 -0800

    [XFRM]: Fix struct xfrm_algo code formatting.
    
    Realign struct members.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index f8507ee..9b5b00c 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -91,9 +91,9 @@ struct xfrm_replay_state
 };
 
 struct xfrm_algo {
-	char	alg_name[64];
+	char		alg_name[64];
 	unsigned int	alg_key_len;    /* in bits */
-	char	alg_key[0];
+	char		alg_key[0];
 };
 
 struct xfrm_stats {
