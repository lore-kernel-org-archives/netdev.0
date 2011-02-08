From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration off
Date: Tue, 8 Feb 2011 23:44:11 +0100
Message-ID: <20110208224411.GA9674@electric-eye.fr.zoreil.com>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net> <4D51BFCE.2070405@msgid.danisch.de> <20110208.143046.246534138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadmut@danisch.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58879 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954Ab1BHWrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 17:47:51 -0500
Content-Disposition: inline
In-Reply-To: <20110208.143046.246534138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Hadmut Danisch <hadmut@danisch.de>
> Date: Tue, 08 Feb 2011 23:12:30 +0100
> 
> > On 08.02.2011 22:44, David Miller wrote:
> >>
> >> This is a case where we're probably just following what the RFC documents
> >> state we should do, which means unless you can provide clear reference to
> >> a specification that states we should behave otherwise this isn't changing.
> > 
> > Could you cite where exactly this is stated in the RFC documents?
> 
> I'm working on other bugs at the moment, so I am personally unable to
> help you with this at this time.  Perhaps someone else can.

This one MAY^W may be relevant (see http://www.ietf.org/rfc/rfc4862.txt) :

Thomson, et al.             Standards Track                     [Page 3]

RFC 4862        IPv6 Stateless Address Autoconfiguration  September 2007
[...]
   The autoconfiguration process specified in this document applies only
   to hosts and not routers.  Since host autoconfiguration uses
   information advertised by routers, routers will need to be configured
   by some other means.  However, it is expected that routers will
   generate link-local addresses using the mechanism described in this
   document.  In addition, routers are expected to successfully pass the
   Duplicate Address Detection procedure described in this document on
   all addresses prior to assigning them to an interface.

--
Ueimor
