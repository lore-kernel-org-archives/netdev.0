From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 01:03:29 -0700 (PDT)
Message-ID: <20081026.010329.11475786.davem@davemloft.net>
References: <1224892008.3919.27.camel@johannes.berg>
	<49035AF0.6040700@anduras.de>
	<1225008096.3478.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anders@anduras.de, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbYJZIDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 04:03:52 -0400
In-Reply-To: <1225008096.3478.3.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sun, 26 Oct 2008 09:01:36 +0100

> On Sat, 2008-10-25 at 19:44 +0200, Sven Anders wrote:
> > Johannes Berg schrieb:
> > > This adds a new printf format specifier for the kernel, %pM,
> > > to be used to print out MAC addresses. This has advantages
> > > over the current print_mac scheme:
> > >  * no need for DECLARE_MAC_BUF
> > >  * can be used safely in statements that might be compiled
> > >    out without the print_mac call staying.
> > 
> > Nice, have you though of something similar for IPv4 and IPv6
> > adresses?
> 
> Not really, are they printed often? I haven't had to touch much code
> that printed IP addresses. Nor have I seen them in logs a lot.

It would be a nice future project for someone.  But don't worry
about it for now.

