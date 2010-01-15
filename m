From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Fri, 15 Jan 2010 00:50:29 -0800 (PST)
Message-ID: <20100115.005029.214418777.davem@davemloft.net>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
	<412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751415Ab0AOIuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:50:20 -0500
In-Reply-To: <412e6f7f1001141822pffa070ap15c73e2931402294@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 15 Jan 2010 10:22:03 +0800

> For connection based packet processing, such as netfilter,
> distributing the packets in two directions into one CPU will reduce
> cache miss, when NAT isn't used. I think the code bellow will help:
> if (addr1 > addr2)
>   swap(addr1, addr2);

You can't just do the addresses, the ports will swap too.
