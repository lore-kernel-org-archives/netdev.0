From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] [AF_PACKET]: Allow multicast traffic to be caught by ORIGDEV when bonded
Date: Wed, 7 Nov 2007 03:00:42 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903ED74CE@orsmsx414.amr.corp.intel.com>
References: <20071106152547.14672.10821.stgit@localhost.localdomain> <20071107.022116.16986000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62680 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbXKGLAo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 06:00:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071107.022116.16986000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > The socket option for packet sockets to return the original ifindex 
> > instead of the bonded ifindex will not match multicast 
> traffic.  Since 
> > this socket option is the most useful for layer 2 traffic and 
> > multicast traffic, make the option multicast-aware.
> > 
> > Signed-off-by: Peter P Waskiewicz Jr 
> <peter.p.waskiewicz.jr@intel.com>
> 
> I agree with you in principle, but I'd like to hear some 
> feedback from other folks.  In particular I'd like a 
> discussion about what this might break, if anything.

That's reasonable.  In any event, the only thing this could affect is if
the option is set on the socket, which shouldn't be very often at all.

I'm more than open to feedback on this change.

Thanks Dave,

-PJ Waskiewicz
