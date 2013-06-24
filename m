From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ip_tunnel: Protect tunnel functions with
 CONFIG_INET guard.
Date: Mon, 24 Jun 2013 00:19:15 -0700 (PDT)
Message-ID: <20130624.001915.528323080820991614.davem@davemloft.net>
References: <1371856631-47807-1-git-send-email-jesse@nicira.com>
	<1371856631-47807-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com,
	rdunlap@infradead.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab3FXHTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:19:16 -0400
In-Reply-To: <1371856631-47807-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 21 Jun 2013 16:17:11 -0700

> Tunnel constants can be used in generic code but in these cases
> the inline functions in ip_tunnels.h cause compilation problems
> if CONFIG_INET is not set.
> 
> CC: Pravin Shelar <pshelar@nicira.com>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
