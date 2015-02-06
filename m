From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm6: Fix a offset value for network header in
 _decode_session6
Date: Fri, 6 Feb 2015 10:16:06 +0100
Message-ID: <20150206091605.GZ13046@secunet.com>
References: <m2d25phhox.wl@sfc.wide.ad.jp>
 <20150205.153854.2003362622735317610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <tazaki@sfc.wide.ad.jp>, <netdev@vger.kernel.org>,
	<herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36482 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157AbbBFJQK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 04:16:10 -0500
Content-Disposition: inline
In-Reply-To: <20150205.153854.2003362622735317610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2015 at 03:38:54PM -0800, David Miller wrote:
> From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
> Date: Wed, 04 Feb 2015 23:31:10 +0900
> 
> > When a network-layer header has multiple IPv6 extension headers, then offset
> > for mobility header goes wrong. This regression breaks an xfrm policy lookup
> > for a particular receive packet. Binding update packets of Mobile IPv6
> > are all discarded without this fix.
> > 
> > Fixes: de3b7a06dfe1 ("xfrm6: Fix transport header offset in _decode_session6.")
> > Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
> 
> Steffen, please review and/or integrate into your tree.

Now applied to the ipsec tree, thanks!
