From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: netlink NETLINK_ROUTE  failure & Can the kernel really handle IPv6
 properly
Date: Wed, 01 Oct 2014 23:30:32 +0200
Message-ID: <1412199032.2532289.174101717.2D6510D0@webmail.messagingengine.com>
References: <542C63FE.9080807@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Ulf Samuelsson <netdev@emagii.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57941 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751516AbaJAVad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 17:30:33 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 9AE8F20B78
	for <netdev@vger.kernel.org>; Wed,  1 Oct 2014 17:30:32 -0400 (EDT)
In-Reply-To: <542C63FE.9080807@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Oct 1, 2014, at 22:28, Ulf Samuelsson wrote:
> BTW, the problem I am trying to solve is how to connect to an I/F with 
> an IPv6 link-local address.
> 
> An existing kernel module waits for a NETDEV_UP event, and then tries to 
> communicate
> with the link-local address.
> 
> This will fail, because (according to a colleague) the I/F enters a 
> "tentative" state,
> where it is trying to decide if it is unique or not.
> It will remain in that state for 1-2 seconds, and only afterwards is the 
> link-local address
> available for normal use.
> 
> The guys writing the module, claim that the kernel is using NETDEV_UP.
> There is very little code in the kernel using NETLINK_ROUTE, even in 
> latest stable.
> It is using NETDEV_UP.
> 
> If my colleague is right, the kernel really cannot handle IPv6 
> link-local addresses properly.

Sorry, I cannot really follow you, can you send example code or be a bit
more precise?

Thanks,
Hannes
