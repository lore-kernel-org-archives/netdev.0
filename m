From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6: Fix tcp_v6_send_response checksum
Date: Thu, 22 Apr 2010 07:19:57 +0800
Message-ID: <20100421231957.GA5903@gondor.apana.org.au>
References: <20100421.004922.193694715.davem@davemloft.net> <20100421.015823.266647388.davem@davemloft.net> <20100421130920.GA31300@gondor.apana.org.au> <20100421.142841.191672280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cratiu@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42484 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755156Ab0DUXUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:20:01 -0400
Content-Disposition: inline
In-Reply-To: <20100421.142841.191672280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 02:28:41PM -0700, David Miller wrote:
> 
> See?  We were computing the checksum over the TCP header twice now :-)
> That's why my patch fixed things for dataless packets, whose
> ->csum would evaluate to zero.

Oh I see, as send_response packets are always dataless this is
corect.

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
