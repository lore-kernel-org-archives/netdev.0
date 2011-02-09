From: Bill Fink <billfink@mindspring.com>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Tue, 8 Feb 2011 23:47:53 -0500
Message-ID: <20110208234753.48abd902.billfink@mindspring.com>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org>
	<20110208.134421.39185637.davem@davemloft.net>
	<4D51BFCE.2070405@msgid.danisch.de>
	<20110208.143046.246534138.davem@davemloft.net>
	<20110208224411.GA9674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadmut@danisch.de,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:35594 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750815Ab1BIE6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 23:58:52 -0500
In-Reply-To: <20110208224411.GA9674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Feb 2011, Francois Romieu wrote:

> David Miller <davem@davemloft.net> :
> > From: Hadmut Danisch <hadmut@danisch.de>
> > Date: Tue, 08 Feb 2011 23:12:30 +0100
> > 
> > > On 08.02.2011 22:44, David Miller wrote:
> > >>
> > >> This is a case where we're probably just following what the RFC documents
> > >> state we should do, which means unless you can provide clear reference to
> > >> a specification that states we should behave otherwise this isn't changing.
> > > 
> > > Could you cite where exactly this is stated in the RFC documents?
> > 
> > I'm working on other bugs at the moment, so I am personally unable to
> > help you with this at this time.  Perhaps someone else can.
> 
> This one MAY^W may be relevant (see http://www.ietf.org/rfc/rfc4862.txt) :
> 
> Thomson, et al.             Standards Track                     [Page 3]
> 
> RFC 4862        IPv6 Stateless Address Autoconfiguration  September 2007
> [...]
>    The autoconfiguration process specified in this document applies only
>    to hosts and not routers.  Since host autoconfiguration uses
>    information advertised by routers, routers will need to be configured
>    by some other means.  However, it is expected that routers will
>    generate link-local addresses using the mechanism described in this
>    document.  In addition, routers are expected to successfully pass the
>    Duplicate Address Detection procedure described in this document on
>    all addresses prior to assigning them to an interface.

I believe there is a difference between being a router and merely
being capable of forwarding IP packets.  To me, a router participates
in a routing protocol and/or advertises routes/prefixes.  So perhaps
Hadmut has a valid point that autoconfiguration should not depend
on ip_forward being off, although I'm not sure what the appropriate
alternate test for not being a router should be.

						-Bill
