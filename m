From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: BUG: dst underflow (again)
Date: Fri, 5 Nov 2004 10:13:41 +0100
Message-ID: <20041105091341.GA28112@xi.wantstofly.org>
References: <4178AB0D.6060107@pobox.com> <20041022.155159.98771450.yoshfuji@linux-ipv6.org> <20041022075947.GA15795@xi.wantstofly.org> <1099577717.1039.155.camel@jzny.localdomain> <20041104221801.584c8f11.davem@davemloft.net> <418B2645.6080404@pobox.com> <20041104231433.3a7233e8.davem@davemloft.net> <418B2D15.5080303@pobox.com> <418B2DEB.4020203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
        hadi@cyberus.ca, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <418B2DEB.4020203@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 05, 2004 at 02:38:19AM -0500, Jeff Garzik wrote:

> BTW to netdev, there is IMHO no excuse not to test IPv6 ;-)

:-)

RIPE hands out IPv6 address space in chunks of /32, and it will only
allocate such a /32 for you if you plan on assigning more than 200 /48's
in two years.

They specify that you should assign a /64 to a customer if they only
need a single subnet, otherwise you should assign a /48.  In order to
assign 200 /48's in two years, you have to assign 200 address blocks
to people who need at least 2 subnets, so that means you have to assign
at least 400 subnets' worth of address space.

If you take the canonical IPv6 subnet to be a /64 and the canonical
IPv4 subnet to be a /24, that means you have to assign a block of IPv6
address space that roughly corresponds to a IPv4 /15 in two years in
order to get IPv6 address space at all.

I politely told RIPE that I don't think we'll be assigning that much
address space any time soon, and the result of that was that our address
space request was simply denied ("because it does not comply with current
policy.")

As a result of all this nonsense, the ISPs in the Netherlands (and
elsewhere) that do supply IPv6 connectivity to their customers resort
to the immensely wasteful practise of giving each and every single
customer an entire /48 because otherwise they will not have assigned
enough address space in two years and risk the wrath of RIPE.

(And there's no way in hell you'll get people to peer with you if you
start sending them 2002:xxxx:xxxx::/48 routes :-)


cheers,
Lennert
