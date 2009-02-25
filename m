From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: xfrm selector generating IKE
Date: Tue, 24 Feb 2009 18:30:41 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02C5BC08@exch-one.centrify.com>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com> <20090224020839.GC18696@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com> <20090225003330.GA29906@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BC01@exch-one.centrify.com> <20090225022745.GA30643@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:22291 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755482AbZBYCao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 21:30:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090225022745.GA30643@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

could u suggest a numbering for my 4 rules - as I said , no combination
I have tried works

// for outbound connections
subnet -> subnet[21] out
subnet[21] -> subnet in
// for inbound connections
subnet[21] -> subnet out
subnet -> subnet[21] in

-----Original Message-----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
Sent: Tuesday, February 24, 2009 6:28 PM
To: Paul Moore
Cc: kaber@trash.net; davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: xfrm selector generating IKE

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
