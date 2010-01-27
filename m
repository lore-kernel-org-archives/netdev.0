From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 02:14:24 -0800 (PST)
Message-ID: <20100127.021424.263649631.davem@davemloft.net>
References: <20100126094817.GA7780@ff.dom.local>
	<20100126103524.GB7780@ff.dom.local>
	<20100127095952.GA11635@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753313Ab0A0KOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 05:14:14 -0500
In-Reply-To: <20100127095952.GA11635@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Jan 2010 09:59:52 +0000

> While looking at the "Deadlock in IPv6 code while garbage collection
> on the rwlock protecting the routing tree" reported by Srinivas
> Akkipeddi I found there is possible a NULL pointer dereference in
> icmp6_dst_alloc().
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Jarek, if rt is NULL so is &rt->u.dst

That's two patches trying to fix this same non-problem in
two different places today :-)
