From: David Miller <davem@davemloft.net>
Subject: Re: SCTP performance?
Date: Fri, 09 Aug 2013 17:54:05 -0700 (PDT)
Message-ID: <20130809.175405.2259209258836008662.davem@davemloft.net>
References: <52057734.6060306@candelatech.com>
	<1376090518.20509.14.camel@edumazet-glaptop>
	<520583AB.9030509@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968075Ab3HJAyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 20:54:06 -0400
In-Reply-To: <520583AB.9030509@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 09 Aug 2013 17:04:59 -0700

> I got much better results when I explicitly set the
> tx/rx socket buffer sizes to 2MB, so maybe it just sucks
> at auto-tuning it's socket buffer sizes.

TCP is the only protocol in our stack which does socket buffer
size autotuning.
