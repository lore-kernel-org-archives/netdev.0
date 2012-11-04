From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] net: inet_diag -- Return error code if protocol handler
 is missed
Date: Sun, 04 Nov 2012 05:39:19 +0400
Message-ID: <5095C747.7090805@parallels.com>
References: <20121103193034.GF6055@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32437 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab2KDBja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2012 21:39:30 -0400
In-Reply-To: <20121103193034.GF6055@moon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2012 11:30 PM, Cyrill Gorcunov wrote:
> We've observed that in case if UDP diag module is not
> supported in kernel the netlink returns NLMSG_DONE without
> notifying a caller that handler is missed.
> 
> This patch makes __inet_diag_dump to return error code instead.
> 
> So as example it become possible to detect such situation
> and handle it gracefully on userspace level.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> CC: David Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Pavel Emelyanov <xemul@parallels.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
