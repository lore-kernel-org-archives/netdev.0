From: David Miller <davem@davemloft.net>
Subject: Re: [2/3] gro: Fix error handling on extremely short frags
Date: Sat, 17 Jan 2009 23:04:28 -0800 (PST)
Message-ID: <20090117.230428.224170102.davem@davemloft.net>
References: <20090118054616.GA24899@gondor.apana.org.au>
	<20090118054718.GA24943@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37549
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755851AbZARHE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:04:27 -0500
In-Reply-To: <20090118054718.GA24943@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 18 Jan 2009 16:47:18 +1100

> gro: Fix error handling on extremely short frags
> 
> When a frag is shorter than an Ethernet header, we'd return a
> zeroed packet instead of aborting.  This patch fixes that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
