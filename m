From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Mon, 24 Sep 2007 09:30:05 +0800
Message-ID: <20070924013005.GB22054@gondor.apana.org.au>
References: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3175 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753493AbXIXBaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 21:30:08 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 23, 2007 at 11:18:58PM +0200, Krzysztof Oledzki wrote:
>
> Thank you for the information. Is there any easy way to turn them on? I 
> need it for LVS.

Do you really need it? The packets should be checksummed at
the point where they physically leave the host.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
