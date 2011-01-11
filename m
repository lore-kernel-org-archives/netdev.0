From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [PATCH 2/3] net/dummy: add device group parameter
Date: Tue, 11 Jan 2011 14:17:46 +0200
Message-ID: <20110111121746.GC26417@cormyr>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
 <1294659524-22509-3-git-send-email-ddvlad@rosedu.org>
 <20110110.133748.85424564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:32856 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755634Ab1AKMSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 07:18:04 -0500
Content-Disposition: inline
In-Reply-To: <20110110.133748.85424564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 01:37:48PM -0800, David Miller wrote:
> From: Vlad Dogaru <ddvlad@rosedu.org>
> Date: Mon, 10 Jan 2011 13:38:43 +0200
> 
> > When inserting the dummy module, the user can specify the group of the
> > dummy devices. This avoids manually moving the newly created pseudo
> > devices to a different group.
> > 
> > Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
> 
> The amount of hacks people wish to add to the dummy driver is one step
> away from amazing.
> 
> Just use the standard APIs to add dummy devices to the group you want,
> instead of these ad-hoc device specific module parameters.

Sorry for attempting to bloat the dummy module. The intention was to be
able to add many dummy interfaces directly into a group without much
user-kernel communication.

However, I think that can be done by moving the existing (hopefully few)
interfaces to another group prior to adding the dummies to group 0 and
using that to manipulate them.

Vlad
