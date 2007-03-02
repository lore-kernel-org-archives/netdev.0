From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 15:41:00 -0800 (PST)
Message-ID: <20070302.154100.30187565.davem@davemloft.net>
References: <20070302.144818.99455241.davem@davemloft.net>
	<20070302.151803.74748558.davem@davemloft.net>
	<20070302153414.4d8304e0@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992759AbXCBXlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 18:41:02 -0500
In-Reply-To: <20070302153414.4d8304e0@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 2 Mar 2007 15:34:14 -0800

> Can you get FC fixed?

I am not the DHCP package maintainer. :-)

I'm up to my earfulls already dealing with people trying
to slug broken patches into the kernel networking that paper
around application bugs. ;)

> Should we add a warning to kernel log, to make distro's fix it?

Unfortunately it looks like a properly formed sockaddr_ll,
the ifindex is in fact zero, so there is nothing we can do
to warn about this case.

The sockaddr_ll sits after the first sockaddr string in the ifreq, and
the rest remains initialized to zeros, thus the bind() succeeds.
