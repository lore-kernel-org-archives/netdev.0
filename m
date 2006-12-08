From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour
 bits
Date: Fri, 08 Dec 2006 13:47:52 -0800 (PST)
Message-ID: <20061208.134752.131916271.davem@davemloft.net>
References: <200612081526.12651.stefan@loplof.de>
	<20061208.133334.55725556.davem@davemloft.net>
	<20061208213614.GA28903@nevyn.them.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, tgraf@suug.ch, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39685
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1947375AbWLHVrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 16:47:47 -0500
To: drow@false.org
In-Reply-To: <20061208213614.GA28903@nevyn.them.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Jacobowitz <drow@false.org>
Date: Fri, 8 Dec 2006 16:36:14 -0500

> On Fri, Dec 08, 2006 at 01:33:34PM -0800, David Miller wrote:
> > From: Stefan Rompf <stefan@loplof.de>
> > Date: Fri, 8 Dec 2006 15:25:18 +0100 (MET)
> > 
> > > The _RTA and _PAYLOAD-macros are also part of userspace headers and need to be
> > > restored. Both dhcpclient and quagga need at least IFA_RTA and IFLA_RTA to
> > > compile, but there may be more macros than in the following patch. You may want
> > > to look at keepalived, iproute, ...
> > 
> > Those are not coming back, sorry.  They are really broken
> > and usage is extremely discouraged.
> > 
> > iproute got fixed, dhcpclient and friends should get fixed to not use
> > them either
> 
> Does this mean glibc should also?

GLIBC does not use them.
