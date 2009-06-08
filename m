From: David Miller <davem@davemloft.net>
Subject: Re: tun: Optimise handling of bogus gso->hdr_len
Date: Mon, 08 Jun 2009 00:22:57 -0700 (PDT)
Message-ID: <20090608.002257.212770666.davem@davemloft.net>
References: <20090604110600.GA28453@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751067AbZFHHWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:22:55 -0400
In-Reply-To: <20090604110600.GA28453@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 4 Jun 2009 21:06:00 +1000

> Hi:
> 
> tun: Optimise handling of bogus gso->hdr_len
> 
> As all current versions of virtio_net generate a value for the
> header length that's too small, we should optimise this so that
> we don't copy it twice.  This can be done by ensuring that it is
> at least as large as the place where we'll write the checksum.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
