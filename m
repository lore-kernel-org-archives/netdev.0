From: David Miller <davem@davemloft.net>
Subject: Re: skb_segment() questions
Date: Sat, 28 Mar 2009 23:39:29 -0700 (PDT)
Message-ID: <20090328.233929.160905643.davem@davemloft.net>
References: <f0ed9b110903041912v6fba381fm4da792d49b1cbb91@mail.gmail.com>
	<20090329020701.GA9983@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamesclhuang@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752702AbZC2Gjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 02:39:41 -0400
In-Reply-To: <20090329020701.GA9983@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 29 Mar 2009 10:07:01 +0800

> gso: Fix support for linear packets
> 
> When GRO/frag_list support was added to GSO, I made an error
> which broke the support for segmenting linear GSO packets (GSO
> packets are normally non-linear in the payload).
> 
> These days most of these packets are constructed by the tun
> driver, which prefers to allocate linear memory if possible.
> This is fixed in the latest kernel, but for 2.6.29 and earlier
> it is still the norm.
> 
> Therefore this bug causes failures with GSO when used with tun
> in 2.6.29.
> 
> Reported-by: James Huang <jamesclhuang@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
