From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC net-next] treewide: s/ipv4_is_<foo>()/ipv4_addr_<foo>/
Date: Thu, 11 Oct 2012 09:11:18 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7037@saturn3.aculab.com>
References: <1349894559.2035.12.camel@joe-AO722> <1349895710.21172.7235.camel@edumazet-glaptop> <1349897005.2035.24.camel@joe-AO722> <1349897923.2035.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"Brian Haley" <brian.haley@hp.com>
To: "Joe Perches" <joe@perches.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1349897923.2035.31.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ipv4 and ipv6 use different styles for these tests.
> 
> ipv4_is_<foo>(__be32)
> ipv6_addr_<foo>(struct in6_addr *)

I presume there is a 'const' in there ...

> Perhaps it'd be good to convert the ipv4 tests to the ipv6 style.

You don't want to force an IPv4 address (which might be in a register)
be written out to stack.
Taking the address also has implications for the optimiser.

	David
