From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Thu, 29 Nov 2007 23:01:12 +1100
Message-ID: <20071129120112.GJ22537@gondor.apana.org.au>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com> <20071129092136.GB30066@gondor.apana.org.au> <474E8F9E.7040309@cn.fujitsu.com> <20071129105648.GB17629@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2753 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762927AbXK2MBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 07:01:25 -0500
Content-Disposition: inline
In-Reply-To: <20071129105648.GB17629@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 10:56:48AM +0000, Gerrit Renker wrote:
>
> | -   InDatagrams:     Total number of received datagrams.
> | +   InDatagrams:     The total number of UDP datagrams delivered to UDP users.
> You are in the UDP-Lite documentation -- it should read "UDP-Lite", not UDP.

We could just drop the mention of UDP completely:

	The total number of datagrams delivered to applications.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
