From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 18:25:06 -0700 (PDT)
Message-ID: <20080812.182506.03341781.davem@davemloft.net>
References: <20080813010935.GA29815@gondor.apana.org.au>
	<20080812.181731.249504809.davem@davemloft.net>
	<20080813012129.GA29996@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56309
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752289AbYHMBZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:25:05 -0400
In-Reply-To: <20080813012129.GA29996@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 Aug 2008 11:21:29 +1000

> On Tue, Aug 12, 2008 at 06:17:31PM -0700, David Miller wrote:
> >
> > It seems pointless for us to add features like mmap() support and
> > auxdata if the most important client library and tool users of these
> > features never take it up.
> 
> Well auxdata at least is used by dhcp-common and therefore dhcp-client
> and dhcp-server.

Only because _YOU_ added it :-)

> > libpcap and tcpdump have been notoriously difficult in this area.
> 
> Yes the disconnect between the kernel community and the rest is
> large.  The only successful examples seems to be where the user-
> space code is maintained by a kernel developer, e.g., iproute.

Isn't that the truth...

Alexey was maintaining his own semi-fork of libpcap and tcpdump for
years for the same reasons.

Let's write a real packet capturing tool that will be fast and that we
can add quick support for new kernel features to.

I mean, what other alternative is there?  The pcap/tcpdump folks have
had 10+ years to get their act in gear.
