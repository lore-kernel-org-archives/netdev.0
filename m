From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO: forwading ISATAP packets is very slow with kernel 4.1
Date: Wed, 15 Jul 2015 08:08:49 +0800
Message-ID: <20150715000848.GC29279@gondor.apana.org.au>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60717 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbGOAIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 20:08:53 -0400
Content-Disposition: inline
In-Reply-To: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 12:16:30AM +0200, Wolfgang Walter wrote:
> Hello,
> 
> I upgraded routers from 3.14.x to 4.1.2. Forwarding ISATAP-packets (IPv4 
> packets with IPv6 payload) is very slow with 4.1 if GRO is enabled (youtube 
> for example about 64kbit). Disabling GRO on the interfaces restores 
> performance to values comparable to 3.14.x.
> 
> The kernel is build with IPv6 support but IPv6 is disabled via kernel command 
> line. The router is not a tunnel endpoint, it only forwards the ISATAP-
> packets. MTU is 1500 on both interfaces. Netfilter conntrack is not used and 
> disabling netfilter has no effect.

Can you run some tcpdumps and post the results in the two cases?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
