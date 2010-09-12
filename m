From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sat, 11 Sep 2010 20:30:02 -0700 (PDT)
Message-ID: <20100911.203002.193707453.davem@davemloft.net>
References: <1283852248.2338.160.camel@edumazet-laptop>
	<20100910.125449.235704956.davem@davemloft.net>
	<20100911123140.GA1939@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59654
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751528Ab0ILD3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 23:29:45 -0400
In-Reply-To: <20100911123140.GA1939@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 11 Sep 2010 14:31:40 +0200

> Otherwise seems OK, but I still would like to know the scenario
> demanding this change.

I want to make sk_buff use list_head, including all uses such as
frag_list et al.

If the frag_list chain can be shared, a doubly linked list cannot be
used.

This is someting I've been gradually working on now for more than 2
years :)
