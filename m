From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 netns: init net is used to set bindv6only for new
 sock
Date: Mon, 09 Jun 2008 15:53:49 -0700 (PDT)
Message-ID: <20080609.155349.172421727.davem@davemloft.net>
References: <4847C1EA.6060609@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757047AbYFIWxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:53:50 -0400
In-Reply-To: <4847C1EA.6060609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 05 Jun 2008 14:37:30 +0400

> The bindv6only is tuned via sysctl. It is already on a struct net
> and per-net sysctls allow for its modification (ipv6_sysctl_net_init).
> 
> Despite this the value configured in the init net is used for the
> rest of them.
> 
> Fits both net-2.6 and net-next-26
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6, thanks Pavel.
