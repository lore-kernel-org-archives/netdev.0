From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Tue, 2 Oct 2007 18:40:33 +0800
Message-ID: <20071002104033.GA30281@gondor.apana.org.au>
References: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl> <20070924013005.GB22054@gondor.apana.org.au> <Pine.LNX.4.64.0709241128490.26474@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1400 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751861AbXJBKkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 06:40:46 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709241128490.26474@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 24, 2007 at 11:44:19AM +0200, Krzysztof Oledzki wrote:
> 
> So, with DR mode, packet goes by the lo device (with bad checksum) and 
> then get redirected outside. Unfortunately, when it leaves host it has bad 
> checksum, too. :(

Did you check this by taking a tcpdump on an external host?
Doing a local tcpdump doesn't work as tcpdump won't show the
correct checksum if checksum offload is enabled.

If it's really sending a bogus checksum then it's a bug in
LVS.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
