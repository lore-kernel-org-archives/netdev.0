From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Wed, 12 Jan 2005 16:04:55 -0800
Message-ID: <20050112160455.3b839b21@dxpl.pdx.osdl.net>
References: <20050112222437.GC14280@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rhousley@rsasecurity.com, shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050112222437.GC14280@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Jan 2005 23:24:37 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Hi,
> 
> After struggling with various userland VPN solutions for a while (and
> failing to make IPSEC tunnel mode do what I want), I decided to just
> implement ethernet-in-IP tunneling in the kernel and let IPSEC transport
> mode handle the rest.
> 
> There appeared to be an RFC for ethernet-in-IP already, RFC 3378, so I
> just implemented that.  It's very simple -- slap a 16-bit header (0x3000,
> which is 4 bits of etherip version number and 12 bits of padding) onto
> the beginning of the ethernet packet, and then wrap it in an IP packet.
> 
> Below is what I came up with, against the latest Fedora Core 3 kernel,
> which is 2.6.10-something.  It survives some fairly basic testing between
> a number of different machines, UP and SMP.  (Corresponding iproute2
> patch is available from http://www.wantstofly.org/~buytenh/etherip/ )
> 


Since it is an RFC, any chance of interoperability testing it with
something besides Linux on the other end?

-- 
Stephen Hemminger	<shemminger@osdl.org>
