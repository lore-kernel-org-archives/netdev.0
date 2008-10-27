From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 16:14:14 -0700
Message-ID: <1225149254.6339.4.camel@brick>
References: <1225124904.5440.1.camel@brick>
	 <20081027.123805.134354592.davem@davemloft.net>
	 <1225137542.5396.10.camel@brick>
	 <20081027.154736.178482850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753727AbYJ0XOa@vger.kernel.org>
In-Reply-To: <20081027.154736.178482850.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-10-27 at 15:47 -0700, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Mon, 27 Oct 2008 12:59:02 -0700
> 
> > Add format specifiers for printing out six colon-separated bytes:
> > 
> > MAC addresses (%pM):
> > xx:xx:xx:xx:xx:xx
> > 
> > %#pM is also supported and omits the colon separators.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> Applied, thanks.

Did you happen to have a preference with regard to the specifier for
IPv6 addresses:

I was thinking of using %pI6 to replace NIP6() and NIP6_FMT and using
%#pI6 for NIP6_SEQFMT.

On the IPv4 side, maybe use %pI4 for network endian NIPQUAD() and NIPQUAD_FMT
and then %#pI4 for host-endian HIQUAD(), as displaying the IPv4 address without
the periods isn't useful?

What do you think of that?

Harvey
