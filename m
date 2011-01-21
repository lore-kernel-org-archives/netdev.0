From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4] Convert PPP to frag lists and SKB list accessors
Date: Thu, 20 Jan 2011 23:55:59 -0800 (PST)
Message-ID: <20110120.235559.218093140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750786Ab1AUHzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:55:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks to some stellar testing and debugging work by Paul, my PPP
SKB list handling changes are in a working state and now checked into
net-next-2.6

There is still a stray "head->next" access in ppp_generic.c but this
is a huge step in the right direction.

I'm posting the final of this stuff so people can see what ended up
in the tree after Paul fixed the bugs.
