From: David Miller <davem@davemloft.net>
Subject: Re: tun: Fix crash with non-GSO users
Date: Tue, 14 Apr 2009 02:09:55 -0700 (PDT)
Message-ID: <20090414.020955.142541912.davem@davemloft.net>
References: <20090414042258.GA27159@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49887
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751217AbZDNJKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 05:10:04 -0400
In-Reply-To: <20090414042258.GA27159@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 14 Apr 2009 12:22:58 +0800

> tun: Fix crash with non-GSO users
> 
> When I made the tun driver use non-linear packets as the preferred
> option, it broke non-GSO users because they would end up allocating
> a completely non-linear packet, which triggers a crash when we call
> eth_type_trans.
> 
> This patch reverts non-GSO users to using linear packets and adds
> a check to ensure that GSO users can't cause crashes in the same
> way.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
