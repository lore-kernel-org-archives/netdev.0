From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: Fix kernel crash on rmmod.
Date: Thu, 11 Jul 2013 11:46:17 -0700 (PDT)
Message-ID: <20130711.114617.1413498443504266635.davem@davemloft.net>
References: <1373567886-28494-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490Ab3GKSqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 14:46:19 -0400
In-Reply-To: <1373567886-28494-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 11 Jul 2013 11:38:06 -0700

> vxlan exit module unregisters vxlan net and then it unregisters
> rtnl ops which triggers vxlan_dellink() from __rtnl_kill_links().
> vxlan_dellink() deletes vxlan-dev from vxlan_list which has
> list-head in vxlan-net-struct but that is already gone due to
> net-unregister. That is how we are getting following crash.
> 
> Following commit fixes the crash by fixing module exit path.
 ...
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks for fixing the commit message.
