From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] htb: fix sign extension bug
Date: Fri, 02 Aug 2013 14:53:34 -0700 (PDT)
Message-ID: <20130802.145334.325880684467169033.davem@davemloft.net>
References: <20130801223207.2a9c69e9@nehalam.linuxnetplumber.net>
	<1375450580.3927.12.camel@edumazet-glaptop>
	<20130802082404.600bc55c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab3HBVxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 17:53:35 -0400
In-Reply-To: <20130802082404.600bc55c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 2 Aug 2013 08:24:04 -0700

> There are more signed/unsigned bugs lurking here, and opportunities to
> shrink the structure. (for example prio could be u8). Overall this code
> uses int where unsigned should be used.

If any of them can cause an OOPS like this one could, let's get that
fixed as soon as possible.

Thanks.
