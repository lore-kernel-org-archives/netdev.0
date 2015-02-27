From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] Multicast group join/leave at ip level
Date: Fri, 27 Feb 2015 16:26:11 -0500 (EST)
Message-ID: <20150227.162611.864498157750734820.davem@davemloft.net>
References: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: challa@noironetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754697AbbB0V0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 16:26:13 -0500
In-Reply-To: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madhu Challa <challa@noironetworks.com>
Date: Wed, 25 Feb 2015 09:58:33 -0800

> This series enables configuring multicast group join/leave at ip level
> by extending the "ip address" command.
> 
> It adds a new control socket mc_autojoin_sock and ifa_flag IFA_F_MCAUTOJOIN
> to invoke the corresponding igmp group join/leave api.
> 
> Since the igmp group join/leave api takes the rtnl_lock the code had to
> be refactored by adding a shim layer prefixed by __ that can be invoked
> by code that already has the rtnl_lock. This way we avoid proliferation of
> work queues.
> 
> The first patch in this series does the refactoring for igmp v6.
> Its based on igmp v4 changes that were added by Eric Dumazet.
> 
> The second patch in this series does the group join/leave based on the
> setting of the IFA_F_MCAUTOJOIN flag.

Applied, but I'm wondering how many hacks we are going to add to the
tree simply because openvswitch does all of it's stuff with non-native
tunneling devices...
