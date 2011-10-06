From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Thu, 06 Oct 2011 15:28:23 -0400 (EDT)
Message-ID: <20111006.152823.2209254598484235967.davem@davemloft.net>
References: <20111004041444.793960297@vyatta.com>
	<20111004041509.292932641@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755607Ab1JFT2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:28:25 -0400
In-Reply-To: <20111004041509.292932641@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 03 Oct 2011 21:14:46 -0700

> This is based on an earlier patch by Nick Carter with comments
> by David Lamparter but with some refinements. Thanks for their patience
> this is a confusing area with overlap of standards, user requirements,
> and compatibility with earlier releases.
> 
> It adds a new sysfs attribute 
>    /sys/class/net/brX/bridge/group_fwd_mask
> that controls forwarding of frames with address of: 01-80-C2-00-00-0X
> The default setting has no forwarding to retain compatibility.
> 
> One change from earlier releases is that forwarding of group
> addresses is not dependent on STP being enabled or disabled. This
> choice was made based on interpretation of tie 802.1 standards.
> I expect complaints will arise because of this, but better to follow
> the standard than continue acting incorrectly by default.
> 
> The filtering mask is writeable, but only values that don't forward
> known control frames are allowed. It intentionally blocks attempts
> to filter control protocols. For example: writing a 8 allows
> forwarding 802.1X PAE addresses which is the most common request.
> 
> Reported-by: David Lamparter <equinox@diac24.net>
> Original-patch-by: Nick Carter <ncarter100@gmail.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next.
