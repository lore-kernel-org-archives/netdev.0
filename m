From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Thu, 13 Jan 2005 01:29:59 +0100
Message-ID: <20050113002959.GI14280@xi.wantstofly.org>
References: <20050112222437.GC14280@xi.wantstofly.org> <20050112160455.3b839b21@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050112160455.3b839b21@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2005 at 04:04:55PM -0800, Stephen Hemminger wrote:

> > After struggling with various userland VPN solutions for a while (and
> > failing to make IPSEC tunnel mode do what I want), I decided to just
> > implement ethernet-in-IP tunneling in the kernel and let IPSEC transport
> > mode handle the rest.
> > 
> > There appeared to be an RFC for ethernet-in-IP already, RFC 3378, so I
> > just implemented that.  It's very simple -- slap a 16-bit header (0x3000,
> > which is 4 bits of etherip version number and 12 bits of padding) onto
> > the beginning of the ethernet packet, and then wrap it in an IP packet.
> > 
> > Below is what I came up with, against the latest Fedora Core 3 kernel,
> > which is 2.6.10-something.  It survives some fairly basic testing between
> > a number of different machines, UP and SMP.  (Corresponding iproute2
> > patch is available from http://www.wantstofly.org/~buytenh/etherip/ )
> 
> Since it is an RFC, any chance of interoperability testing it with
> something besides Linux on the other end?

Some googling suggests that OpenBSD implements this as well.

Anyone here with an OpenBSD box on the 'net that's willing to do
some tests?


cheers,
Lennert
