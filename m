From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 04 Feb 2012 16:47:06 -0500 (EST)
Message-ID: <20120204.164706.1648698930132193786.davem@davemloft.net>
References: <RE:_[PATCH]_tcp_v4_send_reset:_binding_oif_to_iif_in_no_sock_case>
	<1328391897-15241-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: shawn.lu@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab2BDVrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:47:12 -0500
In-Reply-To: <1328391897-15241-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Lu <shawn.lu@ericsson.com>
Date: Sat, 4 Feb 2012 13:44:57 -0800

> Binding RST packet outgoing interface to incoming interface
> for tcp v4 when there is no socket associate with it.
> This has few benefits:
> 1. tcp_v6_send_reset already did that.
> 2. This helps tcp connect with SO_BINDTODEVICE set. When
> connection is lost, we still able to sending out RST using
> same interface.
> 3. we are sending reply, it is most likely to be succeed
> if iif is used
> 
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>

Sigh...

Thanks for giving Eric not credit whatsoever for his contributions
and feedback for this fix. :-/
