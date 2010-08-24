From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp_shift_skb_data uses wrong mss in non-gso case?
Date: Tue, 24 Aug 2010 00:46:37 -0700
Message-ID: <20100824074637.GA24604@gondor.apana.org.au>
References: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35219@US01XMB01.org.nasdaqomx.com> <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Evans <robert.evans@nasdaqomx.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:38742 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab0HXHqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 03:46:46 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 03:34:04PM -0700, Jesse Brandeburg wrote:
> CC Ilpo, the creator of this patch being discussed:
> 
> On Tue, Aug 17, 2010 at 3:35 PM, Robert Evans
> > This ends up being troublesome if the segment is later retransmitted and the
> > device driver has trouble with very small gso_size (e1000e seems to be an
> > example).

I don't see the problem.  If mss == skb->len then tcp_shifted_skb
will zero gso_size.

Which code path is setting gso_size to skb->len?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
