From: David Miller <davem@davemloft.net>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Mon, 13 Apr 2015 13:25:28 -0400 (EDT)
Message-ID: <20150413.132528.1354503140185630054.davem@davemloft.net>
References: <1428912255.6534.5.camel@googlemail.com>
	<1428937760.6534.23.camel@googlemail.com>
	<1428939544.3834.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.poehn@gmail.com, netdev@vger.kernel.org, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932348AbbDMRZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:25:30 -0400
In-Reply-To: <1428939544.3834.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Apr 2015 08:39:04 -0700

> On Mon, 2015-04-13 at 17:09 +0200, Sebastian Poehn wrote:
> 
>> Principally the problem is that TPROXY cannot ensure that policy routing is
>> working correctly. Florian suggested me to clean skb->sk in ip_forward. I even think
>> dropping the frame is fine. Not sure if this is suited for mainline.
> 
> No objections from me, this looks very reasonable.

Someone please submit this to me formally.
