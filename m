From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_input() and ->seq oddities
Date: Tue, 12 Feb 2008 22:54:29 -0800 (PST)
Message-ID: <20080212.225429.131949275.davem@davemloft.net>
References: <20080202222226.GB31388@gondor.apana.org.au>
	<20080202235827.GP27894@ZenIV.linux.org.uk>
	<20080203002019.GA32295@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56740
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751314AbYBMGx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:53:58 -0500
In-Reply-To: <20080203002019.GA32295@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 3 Feb 2008 11:20:19 +1100

> [IPSEC]: Fix bogus usage of u64 on input sequence number
> 
> Al Viro spotted a bogus use of u64 on the input sequence number which
> is big-endian.  This patch fixes it by giving the input sequence number
> its own member in the xfrm_skb_cb structure.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
