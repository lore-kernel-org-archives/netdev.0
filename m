From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 2/2] ipv6: Add support for IPsec virtual tunnel
 interfaces
Date: Tue, 27 Aug 2013 13:08:36 +0200
Message-ID: <20130827110836.GE7660@secunet.com>
References: <20130819062623.GN26773@secunet.com>
 <20130819062730.GP26773@secunet.com>
 <1377535058.11709.21.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54942 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321Ab3H0LIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 07:08:38 -0400
Content-Disposition: inline
In-Reply-To: <1377535058.11709.21.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 26, 2013 at 11:37:38AM -0500, Dan Williams wrote:
> On Mon, 2013-08-19 at 08:27 +0200, Steffen Klassert wrote:
> > This patch adds IPv6  support for IPsec virtual tunnel interfaces
> > (vti). IPsec virtual tunnel interfaces provide a routable interface
> > for IPsec tunnel endpoints.
> 
> Are new ioctls for this kind of thing kosher?  Or should it be using
> netlink instead?
> 

Well, I used the existing interface that all tunnels use. In particular
the vti tunnel for ipv4 uses it and the ipv6 side should be similar.

We could extend the netlink interface for tunnels of course, but that's
another issue.
