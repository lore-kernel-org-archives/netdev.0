From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next 0/3] Small IPsec fix
Date: Mon, 9 Dec 2013 07:25:35 +0100
Message-ID: <20131209062535.GI31491@secunet.com>
References: <1383817670-5783-1-git-send-email-fan.du@windriver.com>
 <20131108115459.GT31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.hengli.com.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38919 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932292Ab3LIGZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 01:25:37 -0500
Content-Disposition: inline
In-Reply-To: <20131108115459.GT31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 08, 2013 at 12:54:59PM +0100, Steffen Klassert wrote:
> On Thu, Nov 07, 2013 at 05:47:47PM +0800, Fan Du wrote:
> > Hi
> > 
> > This patchset made below modifications:
> >  - Fix setting policy index with "ip xfrm ... index=xx"
> >    which is currently broken
> > 
> >  - Using correct name space for home agent when migrating
> >    key info.
> > 
> >  - Put xfrm locks into per namespace to improve scalability.
> > 
> > Changelog:
> > v2:
> >   xfrm: Namespacify xfrm state/policy locks
> >   -Fix compile error when CONFIG_NET_NS is unset, thanks for the lovely build robot.
> > 
> > Fan Du (3):
> >   xfrm: Try to honor policy index if it's supplied by user
> >   xfrm: Using the right namespace to migrate key info
> >   xfrm: Namespacify xfrm state/policy locks
> 
> Your patches are currently in the ipsec-next testing branch.

Now applied to ipsec-next, thanks!
