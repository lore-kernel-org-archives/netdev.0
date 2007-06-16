From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Sat, 16 Jun 2007 17:55:55 +1000
Message-ID: <20070616075555.GA23905@gondor.apana.org.au>
References: <20070614.130358.90120374.davem@davemloft.net> <467259DD.7030703@hartkopp.net> <4672F9AE.6070400@hp.com> <20070615.151457.98556461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, oliver@hartkopp.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net,
	urs@isnogud.escape.de, florz@florz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4489 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754831AbXFPNb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2007 09:31:27 -0400
Content-Disposition: inline
In-Reply-To: <20070615.151457.98556461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15, 2007 at 03:14:57PM -0700, David Miller wrote:
> 
> > No, the questions should really be:
> > 
> > 1.  Is IPV6 supported over this media type.
> > 	yes: got to 2
> > 	no:  stop
> > 
> > 2.  Is the device MTU >= IPV6_MIN_MTU
> > 	yes: continue
> > 	no:  stop
> > 
> > Autoconfiguration is a layer on top of IPv6.  Whether it's enabled
> > or not should not dictate whether IPv6 addressed may be configured or not.
> 
> Sounds good to me, patches? :-)

I don't think we need any more patches since right now MTU >= IPV6_MIN_MTU
is the only condition we require before we allow IPv6 addresses to be added
to an interface.

The original patch simply confused this basic IPv6 address support with
IPv6 autoconfiguration.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
