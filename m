From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: Problem with e100.c and packets >mtu in 2.6.4
Date: Mon, 15 Mar 2004 11:59:26 +1030
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1079314166.5676.103.camel@andromache>
References: <Pine.LNX.4.58.0403150035530.27707@mercury.sdinet.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sven-Haegar Koch <haegar@sdinet.de>
In-Reply-To: <Pine.LNX.4.58.0403150035530.27707@mercury.sdinet.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> What is the reason behind this check? Could it be removed from the
> official sources again?

Alternatively, I'd like to suggest that too-big frames
be discarded by all drivers.

The configuration described (an inconsistent MTU in
a subnet) is wrong and having it fail-and-count rather
than subtly "work" (eg, frames up to some hardware-dependent
magic number are received but can't be sent, but frames
beyond that don't) is a significant help to network
operators.

Those operators then just need to know the RFCs, not
the inner details of the popular NICs and their drivers.

-- 
Glen Turner         Tel: (08) 8303 3936 or +61 8 8303 3936 
Network Engineer          Email: glen.turner@aarnet.edu.au
Australian Academic & Research Network   www.aarnet.edu.au
