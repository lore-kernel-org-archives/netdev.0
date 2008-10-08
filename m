From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 15:22:38 -0700
Message-ID: <1223504558.22343.15.camel@w-sridhar2.beaverton.ibm.com>
References: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>
	 <48ED03A6.2060705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:35994 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbYJHWXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 18:23:02 -0400
In-Reply-To: <48ED03A6.2060705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2008-10-08 at 15:01 -0400, Brian Haley wrote:
> David Stevens wrote:
> > Well, actually, it looks like I'm suggesting you to re-use something that 
> > doesn't
> > exist. :-)
> > 
> > MLD (and IGMP) has such a thing where unsolicited advertisements are sent
> > multiple times, with delays in between, to account for lossy networks 
> > possibly
> > dropping the first one. There are configurable counts associated with 
> > probes
> > and retransmit intervals for solicits, but I don't see the equivalent yet 
> > for
> > unsolicited NA's.
> 
> I don't see an equivalent either, since the only unsolicited NA the 
> kernel sends is for DAD, which uses dad_transmits.

Doesn't DAD use neighbor solicitation rather than unsolicited NA?
Can we use NS in the bonding failover scenario too?

Thanks
Sridhar




