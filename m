From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm selector generating IKE
Date: Wed, 25 Feb 2009 10:27:45 +0800
Message-ID: <20090225022745.GA30643@gondor.apana.org.au>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com> <20090224020839.GC18696@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com> <20090225003330.GA29906@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BC01@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59079 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752600AbZBYC1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 21:27:55 -0500
Content-Disposition: inline
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02C5BC01@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 06:07:06PM -0800, Paul Moore wrote:
> You seem to be saying that that if I explicitly set the policy reqids
> that it should work. 
> 
> I had experimented with that a lot 
> 
> The problem is that I cannot find a good combination of reqids 

It's very simple, you want each equivalent class of SAs (i.e.,
SAs where any one can replace the other) to be assigned a unique
reqid.

The Openswan algorithm simply assigns an ID to each policy (or
connection as it stores them internally), and then uses that ID
as the reqid.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
