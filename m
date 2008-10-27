From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
	addresses
Date: Tue, 28 Oct 2008 02:31:53 +0300
Message-ID: <20081027233153.GA11367@x200.localdomain>
References: <1225124904.5440.1.camel@brick> <20081027.123805.134354592.davem@davemloft.net> <1225137542.5396.10.camel@brick> <20081027.154736.178482850.davem@davemloft.net> <1225149254.6339.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	anders@anduras.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:49366 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbYJ0X2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 19:28:31 -0400
Received: by ey-out-2122.google.com with SMTP id 6so929384eyi.37
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 16:28:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1225149254.6339.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2008 at 04:14:14PM -0700, Harvey Harrison wrote:
> On Mon, 2008-10-27 at 15:47 -0700, David Miller wrote:
> > From: Harvey Harrison <harvey.harrison@gmail.com>
> > Date: Mon, 27 Oct 2008 12:59:02 -0700
> > 
> > > Add format specifiers for printing out six colon-separated bytes:
> > > 
> > > MAC addresses (%pM):
> > > xx:xx:xx:xx:xx:xx
> > > 
> > > %#pM is also supported and omits the colon separators.
> > > 
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > 
> > Applied, thanks.
> 
> Did you happen to have a preference with regard to the specifier for
> IPv6 addresses:
> 
> I was thinking of using %pI6 to replace NIP6() and NIP6_FMT and using
> %#pI6 for NIP6_SEQFMT.
> 
> On the IPv4 side, maybe use %pI4 for network endian NIPQUAD() and NIPQUAD_FMT
> and then %#pI4 for host-endian HIQUAD(), as displaying the IPv4 address without
> the periods isn't useful?

%#pI4 is horrible and %p4 and %p6 were cool.
