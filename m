From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 0/2] Removal of struct esp_data
Date: Tue, 29 Oct 2013 13:11:05 +0100
Message-ID: <20131029121105.GF31491@secunet.com>
References: <20131022130822.GA26207@secunet.com>
 <20131022.140510.1879404122981800534.davem@davemloft.net>
 <20131023080716.GA10148@secunet.com>
 <20131023.154002.1833051243694861649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mathias.krause@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50311 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751804Ab3J2MLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:11:08 -0400
Content-Disposition: inline
In-Reply-To: <20131023.154002.1833051243694861649.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 03:40:02PM -0400, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 23 Oct 2013 10:07:16 +0200
> 
> > Well, I thought to either take this as a reminder to implement the
> > missing stuff or to take the removing patches if this is really obsolete.
> > I'll do one of both once I'm back from conference week in Edinburgh.
> 
> Sounds like a good plan, thanks.

RFC 4303 recommends to use TFC padding instead of the padding field:

'As noted above, the Padding field is limited to 255 bytes in length.
This generally will not be adequate to hide traffic characteristics
relative to traffic flow confidentiality requirements.  An optional
field, within the payload data, is provided specifically to address
the TFC requirement.'

So looks like we can remove the padlen field, both patches
applied to ipsec-next. Thanks Mathias!
