From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use sockfd_lookup_light in the rest of the net/socket.c
Date: Wed, 14 Nov 2007 16:02:16 -0800 (PST)
Message-ID: <20071114.160216.78473920.davem@davemloft.net>
References: <473B256A.8080104@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36256
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752161AbXKOACR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 19:02:17 -0500
In-Reply-To: <473B256A.8080104@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 14 Nov 2007 19:42:18 +0300

> Some time ago a sockfd_lookup_light was introduced and
> most of the socket.c file was patched to use it. However
> two routines were left - sys_sendto and sys_recvfrom.
> 
> Patch them as well, since this helper does exactly what
> these two need.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25, thanks!
