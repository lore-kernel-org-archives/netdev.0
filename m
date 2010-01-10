From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Sun, 10 Jan 2010 13:15:24 -0800 (PST)
Message-ID: <20100110.131524.241344047.davem@davemloft.net>
References: <55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
	<20100107.171015.29035630.davem@davemloft.net>
	<b91784ff1001081612g7c15e968u5e77931289af25c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437Ab0AJVPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 16:15:15 -0500
In-Reply-To: <b91784ff1001081612g7c15e968u5e77931289af25c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 8 Jan 2010 16:12:55 -0800

> How about this patch instead?

It's still not fully correct.

You can't ignore source based routing and pretend it doesn't
exist or matter.

That's why ipv4 (and this code you are trying to change) needs to
iterate over saddr [ ANY, saddr ], and that's why you need that
special loop that iterates over all combinations of ifindex/saddr.

This is what I've been asking you to do from the beginning, please
implement it this way and I'll apply your patch.
