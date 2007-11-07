From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] [AF_PACKET]: Allow multicast traffic to be caught by ORIGDEV when bonded
Date: Wed, 7 Nov 2007 09:40:28 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903F13920@orsmsx414.amr.corp.intel.com>
References: <20071106152547.14672.10821.stgit@localhost.localdomain><20071107.022116.16986000.davem@davemloft.net><D5C1322C3E673F459512FB59E0DDC32903ED74CE@orsmsx414.amr.corp.intel.com> <20071107.035206.187180402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18998 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754250AbXKGRkb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 12:40:31 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071107.035206.187180402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, November 07, 2007 3:52 AM
> To: Waskiewicz Jr, Peter P
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH] [AF_PACKET]: Allow multicast traffic to 
> be caught by ORIGDEV when bonded
> 
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Wed, 7 Nov 2007 03:00:42 -0800
> 
> > In any event, the only thing this could affect is if the 
> option is set 
> > on the socket, which shouldn't be very often at all.
> 
> Any idea how many programs set this option and which ones?  
> You obviously noticed, so perhaps you know at least one or 
> was this discovered purely by code inspection?

We have an application that communicates with a switch and a NIC that
helps some additional configuration for the network (think of it as an
extended link negotiation).  It uses LLDP, which is layer 2 and is
multicast.  We noticed that when testing bonding, it didn't work.  I'm
not sure who else might be using this code right now, since it went into
the mainstream kernel in 2.6.22.

Thanks,
-PJ
