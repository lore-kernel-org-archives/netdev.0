From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 18:17:31 -0700 (PDT)
Message-ID: <20080812.181731.249504809.davem@davemloft.net>
References: <20080812233753.GA29155@gondor.apana.org.au>
	<20080812.175532.137434164.davem@davemloft.net>
	<20080813010935.GA29815@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753352AbYHMBR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:17:29 -0400
In-Reply-To: <20080813010935.GA29815@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 Aug 2008 11:09:35 +1000

> On Tue, Aug 12, 2008 at 05:55:32PM -0700, David Miller wrote:
> > I kind of hope that libpcap/tcpdump has been taught about auxdata
> > by now, has it? :-/
> 
> Unfortunately no.  This also means that if we do do this in AF_PACKET,
> then running a packet dump on a fast outbound interface may become more
> expensive.

It seems pointless for us to add features like mmap() support and
auxdata if the most important client library and tool users of these
features never take it up.

libpcap and tcpdump have been notoriously difficult in this area.
