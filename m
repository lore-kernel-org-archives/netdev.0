From: Joe Perches <joe@perches.com>
Subject: Re: [RFC net-next] treewide: s/ipv4_is_<foo>()/ipv4_addr_<foo>/
Date: Thu, 11 Oct 2012 01:28:35 -0700
Message-ID: <1349944115.2243.18.camel@joe-AO722>
References: <1349894559.2035.12.camel@joe-AO722>
	 <1349895710.21172.7235.camel@edumazet-glaptop>
	 <1349897005.2035.24.camel@joe-AO722> <1349897923.2035.31.camel@joe-AO722>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7037@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brian Haley <brian.haley@hp.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7037@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-10-11 at 09:11 +0100, David Laight wrote:
> > ipv4 and ipv6 use different styles for these tests.
> > 
> > ipv4_is_<foo>(__be32)
> > ipv6_addr_<foo>(struct in6_addr *)
> 
> I presume there is a 'const' in there ...
> 
> > Perhaps it'd be good to convert the ipv4 tests to the ipv6 style.
> 
> You don't want to force an IPv4 address (which might be in a register)
> be written out to stack.
> Taking the address also has implications for the optimiser.

Of course not, I'm just talking about renaming.
