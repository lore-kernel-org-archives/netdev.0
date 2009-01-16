From: jpo234@netscape.net
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 05:46:30 -0500
Message-ID: <8CB45DED3262281-2F30-8C9@webmail-stg-d07.sysops.aol.com>
References: <20090116064840.GA12399@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m23.mx.aol.com ([64.12.137.4]:53029 "EHLO
	imo-m23.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400AbZAPKrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 05:47:15 -0500
In-Reply-To: <20090116064840.GA12399@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert,
sorry for bothering you (and everybody else on the list) again. It 
seems that the stack does not replace a "::" source address with a real 
one when using a PF_INET6/SOCK_RAW/IPPROTO_RAW socket the way it does 
with an IP_HDRINCL IPv4 socket for "0.0.0.0". Do I have to fill this 
one myself or is there another trick to achieve this?

Thanks and kind regards
  Joerg

-----Original Message-----
From: Herbert Xu <herbert@gondor.apana.org.au>
To: jpo234@netscape.net
Cc: netdev@vger.kernel.org
Sent: Fri, 16 Jan 2009 7:48 am
Subject: Re: Sending complete IPv6 packets without bypassing 
netfilter/IPsec

jpo234@netscape.net wrote:
>
> So, if you write "should have the same effect as IP_HDRINCL" does 
this
> mean "this is the way we designed it in Linux, so it should work" or

It's designed this way in Linux.

Cheers,
--
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt





