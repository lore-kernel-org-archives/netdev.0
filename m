From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Add support for rx flow hash configuration in a
 network device
Date: Sun, 29 Jun 2008 13:49:36 -0700 (PDT)
Message-ID: <20080629.134936.139001500.davem@davemloft.net>
References: <48658078.8030707@Sun.COM>
	<871w2gph8r.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Santwona.Behera@Sun.COM, netdev@vger.kernel.org, jeff@garzik.org,
	Matheos.Worku@Sun.COM, Michael.Speer@Sun.COM,
	gkernel-commit@lists.sourceforge.net
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41654
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753891AbYF2Utg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 16:49:36 -0400
In-Reply-To: <871w2gph8r.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sun, 29 Jun 2008 14:17:56 +0200

> Are you sure ethtool is the right interface for this?

Yes.

> Me thinks the kernel should just do the right thing automatically
> for this, by distributing the flows over CPUs.

How the work, and what kind of work, should be distributed across the
machine is the user's business.

Or maybe we should just get rid of all of those NUMA knobs we have
too?

We've discussed this before and Jeff Garzik and I already told
everyone that we want to make this configurable and ethtool is
the way to do it no matter how adhoc and device specific the
interfaces might end up being.

Please don't send submitters mixed messages like this after we've
told them to do things this way, it only leads to discouragement
for new contributors.
