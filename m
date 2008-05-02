From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener for DCB runtime changes.
Date: Fri, 2 May 2008 13:08:21 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290501D2E7@orsmsx414.amr.corp.intel.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain> <20080502004300.14392.87943.stgit@localhost.localdomain> <481AF501.3030507@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38888 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756277AbYEBUIU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:08:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <481AF501.3030507@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Seems to me we don't want each driver supporting this 
> technology to create their own netlink interface...

Definitely reasonable.  However, even with an ethtool interface, there's
going to be a good chunk of development.  Is the issue just the
non-generic netlink family we're implementing, or is it something else?

> This seems more appropriate via ethtool, or ethtool-netlink 
> (Thomas Graf posted an RFC)

Oddly enough, we made the decision early on in development not to use
ethtool.  We would be adding a rather large number of ioctls for this
technology, and our initial thoughts were that the community would
reject that large of a change to the ethtool interface.

I'm very interested in the ethtool-netlink interface, which would
probably help us get rid of the ixgbe_is_ixgbe() call in the DCB driver.

Aside from the netlink issues, how does the rest of the code appear?
Thanks for the feedback Jeff.

Cheers,
-PJ Waskiewicz
