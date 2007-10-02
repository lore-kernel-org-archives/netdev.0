From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Tue, 2 Oct 2007 22:17:49 +0800
Message-ID: <20071002141749.GA31978@gondor.apana.org.au>
References: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl> <20070924013005.GB22054@gondor.apana.org.au> <Pine.LNX.4.64.0709241128490.26474@bizon.gios.gov.pl> <20071002104033.GA30281@gondor.apana.org.au> <Pine.LNX.4.64.0710021606550.3175@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2950 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751300AbXJBORx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:17:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710021606550.3175@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 04:15:15PM +0200, Krzysztof Oledzki wrote:
>
> I'm not sure if we should call it a bug. LVS does not support such 
> configuration by default - it requires kernel patching. However, it worked 
> with older kernels so that's why I asked if it is possible to force full 
> TCP/UDP checksum calculation?

This is no different than DNATing a packet originally destined
for lo to eth0, which works fine BTW.  So that LVS patch or LVS
itself should be fixed to do the right thing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
