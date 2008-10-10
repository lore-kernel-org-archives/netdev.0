From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on
	failover
Date: Fri, 10 Oct 2008 09:56:12 -0700
Message-ID: <1223657772.10489.5.camel@w-sridhar2.beaverton.ibm.com>
References: <OFB8A232B8.61496942-ON882574DE.0051B425-882574DE.0052AFD3@us.ibm.com>
	 <29444.1223654036@death.nxdomain.ibm.com> <48EF7CFF.4050405@hp.com>
	 <48EF82D2.6030008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jay Vosburgh <fubar@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46608 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758428AbYJJQ4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 12:56:16 -0400
In-Reply-To: <48EF82D2.6030008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-10-10 at 12:29 -0400, Vlad Yasevich wrote:
> Brian Haley wrote:
> > Jay Vosburgh wrote:
> >>     As a semi-related question, what does IPv6 do if it receives a
> >> gratutitous NA, and finds a duplicate?

I think Jay was asking about the case where the target address in the NA 
matches the address of the receiving interface. The RFCs don't describe
how to handle such a case and leave it to the implementation. Linux logs
a warning message and ignores such NA.

Thanks
Sridhar

> > 
> > If a node has an IPv6 neighbor entry and receives an unsolicited NA it
> > will change it's state to stale, forcing a re-lookup on the next
> > transmit.  An un-solicited NA will change the state to reachable.
>                 ^^^^^^^^^^^^
> 
> You probably meant to say "solicited".  Unsolicited NAs can only change
> the state to STALE.
> 
> Also, the re-lookup will happen on a delay after the transmit.
> 
> -vlad


