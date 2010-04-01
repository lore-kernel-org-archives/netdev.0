From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 1 Apr 2010 10:52:47 +0800
Message-ID: <20100401025247.GA19994@gondor.apana.org.au>
References: <1270053478.26743.111.camel@bigi> <20100401003352.GA19147@gondor.apana.org.au> <1270089323.26743.138.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:59380 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752539Ab0DACxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 22:53:09 -0400
Content-Disposition: inline
In-Reply-To: <1270089323.26743.138.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 10:35:23PM -0400, jamal wrote:
> On Thu, 2010-04-01 at 08:33 +0800, Herbert Xu wrote:
> 
> > If we're going to change this then we should just add a second
> > interface field to the selector, rather than trying to overload
> > the existing one.
> 
> Do you mean to have a selector->iif/oif? Sure that makes sense - but is
> a much larger surgery and user space will need to be taught.
> 
> Did you look at the patch i sent? i tried to retain current behavior
> except for the input check path. output path was working in classifying
> with specific netdevs. 

OK, I guess the chances of an existing app breaking is slim.

BTW, you should treat FLOW_DIR_FWD as FLOW_DIR_IN.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
