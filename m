From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] Consolidate the xxx_evictor
Date: Mon, 15 Oct 2007 02:40:14 -0700 (PDT)
Message-ID: <20071015.024014.101853487.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F758B.5090508@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757994AbXJOJkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:40:09 -0400
In-Reply-To: <470F758B.5090508@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:24:27 +0400

> The evictors collect some statistics for ipv4 and ipv6, 
> so make it return the number of evicted queues and account
> them all at once in the caller.
> 
> The XXX_ADD_STATS_BH() macros are just for this case, 
> but maybe there are places in code, that can make use of 
> them as well.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
