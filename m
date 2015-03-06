From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tipc: add ip/udp media type
Date: Thu, 05 Mar 2015 22:10:53 -0500 (EST)
Message-ID: <20150305.221053.765517308747813039.davem@davemloft.net>
References: <1425547429-21164-1-git-send-email-erik.hugne@ericsson.com>
	<1425547429-21164-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbbCFDKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:10:55 -0500
In-Reply-To: <1425547429-21164-2-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 5 Mar 2015 10:23:49 +0100

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> The ip/udp bearer can be configured in a point-to-point
> mode by specifying both local and remote ip/hostname,
> or it can be enabled in multicast mode, where links are
> established to all tipc nodes that have joined the same
> multicast group. The multicast IP address is generated
> based on the TIPC network ID, but can be overridden by
> using another multicast address as remote ip.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.

But this shows a general problem with NET_UDP_TUNNEL, it's
something everyone using 'select' on, but that's broken
because NET_UDP_TUNNEL is not a leaf node and rather has
dependencies of it's own that it 'select'.  But 'select x'
does not cause x's select statements to be executed.

It all just works by luck right now :-/
