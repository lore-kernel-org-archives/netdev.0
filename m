From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] igbvf: add new driver to support 82576
 virtual functions
Date: Wed, 25 Mar 2009 16:58:47 -0700 (PDT)
Message-ID: <20090325.165847.234084422.davem@davemloft.net>
References: <20090325215248.28529.62295.stgit@lost.foo-projects.org>
	<20090325150322.40e0a1e6@nehalam>
	<49CAB13B.7070601@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752251AbZCYX7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 19:59:00 -0400
In-Reply-To: <49CAB13B.7070601@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 25 Mar 2009 15:33:31 -0700

> The sysfs part of this is already in net-next as it isn't part of
> the igbvf driver it is part of igb.  It was added in over a month
> ago: http://patchwork.ozlabs.org/patch/23471/
> 
> I will see what we can do to make use of a netlink interface.  I'm
> honestly not even sure if it will work well for this kind of setup
> since the VF driver won't even be running on the same OS in most
> cases.  For now the sysfs code in igb is actually quite minimal, and
> the main goal was to keep the interface as simple as possible which
> is what I have done.

I have to agree with Stephen that the way to create new links
of virtual and similar devices is to use rtnl_link.

We have very good infrastructure for this, and if I understand
things correctly iproute2 might even work with an igb using
rtnl_link with zero modifications to the tool sources.

Please fix this up, it's a very reasonable request for such
a large new piece of driver infrastructure.  And since this is
a new driver, you have no time constraints for submission either.

