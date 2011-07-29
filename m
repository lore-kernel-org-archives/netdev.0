From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Fix key lengths for rfc3686(ctr(aes))
Date: Thu, 28 Jul 2011 18:25:50 -0700 (PDT)
Message-ID: <20110728.182550.32786681614701904.davem@davemloft.net>
References: <alpine.LFD.1.10.1107281246381.11308@net-test1.az.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: tgohad@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647Ab1G2B16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 21:27:58 -0400
In-Reply-To: <alpine.LFD.1.10.1107281246381.11308@net-test1.az.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Gohad <tgohad@mvista.com>
Date: Thu, 28 Jul 2011 13:36:20 -0700 (MST)

> 
> Fix the min and max bit lengths for AES-CTR (RFC3686) keys.
> The number of bits in key spec is the key length (128/256)
> plus 32 bits of nonce.
> 
> This change takes care of the "Invalid key length" errors
> reported by setkey when specifying 288 bit keys for aes-ctr.
> 
> Signed-off-by: Tushar Gohad <tgohad@mvista.com>

APplied.
