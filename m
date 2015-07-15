From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO: forwading ISATAP packets is very slow with kernel 4.1
Date: Wed, 15 Jul 2015 17:50:20 +0800
Message-ID: <20150715095019.GA881@gondor.apana.org.au>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
 <20150715000848.GC29279@gondor.apana.org.au>
 <8145949.lUzHGl5xdY@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49974 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbbGOJuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 05:50:25 -0400
Content-Disposition: inline
In-Reply-To: <8145949.lUzHGl5xdY@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 02:34:41AM +0200, Wolfgang Walter wrote:
> 
> I wonder if the router may treat all ipv6-tcp connections of a host as a 
> single flow as all those ipv6-packets are embedded in ipv4-packets with the 
> ipv4-address of the host and the ipv4-address of the isatap-gateway and next-
> header is 41. It may only looks at those?

I think GRO is actually working fine.  Can you show me the output
of ethtool -k eth1? If hardware TSO is enabled can you try disabling
it to see if it helps?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
