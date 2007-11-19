From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Mon, 19 Nov 2007 00:30:17 -0800 (PST)
Message-ID: <20071119.003017.223165152.davem@davemloft.net>
References: <20071118214515.GA8161@one.firstfloor.org>
	<20071118.144010.236028466.davem@davemloft.net>
	<4740EE9B.40901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37449
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbXKSIaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 03:30:18 -0500
In-Reply-To: <4740EE9B.40901@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 19 Nov 2007 10:02:03 +0800

> So if "udp_queue_rcv_skb() doing sucessfully" means "a UDP
> datagrams delivered to UDP users", the InDatagrams should be
> increased in udp_queue_rcv_skb().
> Otherwise it should be increased until the UDP datagrams is
> actually delivered to UDP users.

I agree.
