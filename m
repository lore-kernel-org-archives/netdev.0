From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: skb ftracer - add tracepoint to
 skb_copy_datagram_iovec (v3)
Date: Thu, 13 Aug 2009 16:28:14 -0700 (PDT)
Message-ID: <20090813.162814.06934096.davem@davemloft.net>
References: <20090807202130.GA26677@hmsreliant.think-freely.org>
	<20090813145917.GA16521@hmsreliant.think-freely.org>
	<20090813151944.GA16682@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56568
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755933AbZHMX2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:28:03 -0400
In-Reply-To: <20090813151944.GA16682@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 13 Aug 2009 11:19:44 -0400

> skb allocation / cosumption tracer - Add consumption tracepoint
> 
> This patch adds a tracepoint to skb_copy_datagram_iovec, which is called each
> time a userspace process copies a frame from a socket receive queue to a user
> space buffer.  It allows us to hook in and examine each sk_buff that the system
> receives on a per-socket bases, and can be use to compile a list of which skb's
> were received by which processes.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


Applied to net-next-2.6
