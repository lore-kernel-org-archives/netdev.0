From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/3] ipv4: Fix packet size calculation for IPsec
 packets in __ip_append_data
Date: Wed, 8 Jun 2011 07:30:20 +0200
Message-ID: <20110608053020.GA6489@secunet.com>
References: <20110606064603.GB31505@secunet.com>
 <20110606064802.GC31505@secunet.com>
 <1307345899.3098.3.camel@edumazet-laptop>
 <20110606085247.GE31505@secunet.com>
 <1307423217.2642.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48335 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143Ab1FHF0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 01:26:53 -0400
Content-Disposition: inline
In-Reply-To: <1307423217.2642.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2011 at 07:06:57AM +0200, Eric Dumazet wrote:
> 
> Nick mail was :
> 
> http://www.spinics.net/lists/netdev/msg141308.html
> 

Thanks for providing these informations.

> Unfortunatly I could not find on my machines where I put my own
> scripts...
> 
> Not a big deal, I suspect we can revert my commit if you say it added a
> regression :)
> 

In between I can confirm that we get the slowpath problem back with my
patch, so we still have a bug somewhere. Reverting your commit would
be just a band aid. I think it is better to find the bug and do a real
fix instead. Unfortunatly I fear I'm not able to track it down before
my vacation that starts tomorrow. I'll continue to work at it once I'm
back...
