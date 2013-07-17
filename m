From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: Fix kernel crash on rmmod.
Date: Tue, 16 Jul 2013 23:03:29 -0700 (PDT)
Message-ID: <20130716.230329.1083297294985100982.davem@davemloft.net>
References: <1373567886-28494-1-git-send-email-pshelar@nicira.com>
	<20130711.114617.1413498443504266635.davem@davemloft.net>
	<20130716163156.2374b233@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab3GQGDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 02:03:30 -0400
In-Reply-To: <20130716163156.2374b233@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 16 Jul 2013 16:31:56 -0700

> The root cause is that rtnl_kill_links calls dellink even if device is still
> UP. Since this a generic problem (several other tunnels will crash or leak
> if rmmod when up), I am working on a generic fix.

Ok, thanks for the info.
