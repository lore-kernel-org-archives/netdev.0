From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Don't declare extern variables in
 net/core/sysctl_net_core.c
Date: Tue, 23 Oct 2007 21:14:08 -0700 (PDT)
Message-ID: <20071023.211408.70220657.davem@davemloft.net>
References: <471CC043.5060301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751915AbXJXEOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 00:14:24 -0400
In-Reply-To: <471CC043.5060301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 22 Oct 2007 19:22:43 +0400

> Some are already declared in include/linux/netdevice.h, while
> some others (xfrm ones) need to be declared.
> 
> The driver/net/rrunner.c just uses same extern as well, so 
> cleanup it also.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
