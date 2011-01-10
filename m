From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: add device groups
Date: Mon, 10 Jan 2011 15:08:25 +0100
Message-ID: <1294668505.3583.9.camel@jlt3.sipsolutions.net>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	 <1294666875.3583.6.camel@jlt3.sipsolutions.net>
	 <1294668021.6063.315.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:58425 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753650Ab1AJOI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:08:29 -0500
In-Reply-To: <1294668021.6063.315.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-10 at 09:00 -0500, jamal wrote:
> On Mon, 2011-01-10 at 14:41 +0100, Johannes Berg wrote:
> 
> > Can you explain the purpose of this? I'm wondering if it would make
> > sense to automatically group all virtual interfaces belonging to a
> > single 802.11 device, for instance.
> 
> It depends what you want to do with that grouping.
> In a nutshell, this greatly reduces the amount of kernel-user netlink
> traffic in presence of multi interfaces.
> you can do things like:
>  
> ip link set dev ppp0 group 1
> ...
> ...
> ip link set dev pppN group 1
> 
> ip link ls group 1
> ip link set down group 1
> ip link set mtu 512 group 1
> etc

Right, but where would you want to use it -- what's the use case right
now? Your ppp example here makes me think the use case is some PPP
endpoint server that has lots of these interfaces. It also means the
grouping is entirely user-space controlled. In this case, the idea of
automatically grouping based on the device structure seems pointless.

johannes

