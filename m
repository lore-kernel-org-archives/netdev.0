From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: Question about IPv6 neighbor discovery and 6lowpan
Date: Thu, 21 Nov 2013 17:52:15 +0200
Message-ID: <1385049135.2723.25.camel@jrissane-mobl.ger.corp.intel.com>
References: <1385046178.2723.17.camel@jrissane-mobl.ger.corp.intel.com>
	 <20131121153414.GA9960@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11237 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab3KUPwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 10:52:46 -0500
In-Reply-To: <20131121153414.GA9960@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On to, 2013-11-21 at 16:34 +0100, Alexander Aring wrote:
> Hi Jukka,
> 
> On Thu, Nov 21, 2013 at 05:02:58PM +0200, Jukka Rissanen wrote:
> > Hi,
> > 
> > I am investigating RFC 6775 (Neighbor Discovery Optimization for IPv6
> > over Low-Power Wireless Personal Area Networks (6LoWPANs))
> > http://tools.ietf.org/html/rfc6775
> > 
> > The RFC suggests some changes to neighbor discovery procedure for the
> > 6LoWPAN networks. I was looking net/ipv6/ndisc.c and it seems that
> > ARPHRD type (from type field in net_device struct) is the only way to
> > detect and change the discovery procedure in the ndisc.c code. Am I
> > right with this assumption here?
> > 
> I think you are right, there was some patches on linux-zigbee-devel who
> use exact the same idea to check the ARPHRD type.

Ok. The reason I was interested in about this is that I proposed new
ARPHRD_RAWIP earlier that I could use in BT LE 6lowpan code. Now I think
that type might be too generic and perhaps I should have ARPHRD_6LOWPAN
or even ARPHRD_BT_6LOWPAN.

> 
> But I am investigating for rfc6775, too. :-)
> 
> 
> At the moment I see too many unsolved issues in the ieee802154/6lowpan
> implementation which should be fixed at first. :(
> 
> - Alex

No worries, the rfc6775 is common for both zigbee and bluetooth so
whoever implements the rfc gets support for both of them at the same
time.


Cheers,
Jukka
