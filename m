From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH 0/3] UDP memory usage accounting
Date: Fri, 28 Sep 2007 21:51:59 -0700 (PDT)
Message-ID: <20070928.215159.58440039.davem@davemloft.net>
References: <46FD0117.9030407@hitachi.com>
	<E1IbSt7-000091-00@gondolin.me.apana.org.au>
	<20070928.214737.120464821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satoshi.oshima.fk@hitachi.com, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, haoki@redhat.com, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751679AbXI2EwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 00:52:00 -0400
In-Reply-To: <20070928.214737.120464821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 28 Sep 2007 21:47:37 -0700 (PDT)

> Per-user limits are not necessarily the answer.

Seeing myself say this reminds me that it seems to have been missed in
all of this that we do have a limit per user already.

There is a per-socket send buffer limit, and there is a per-user open
file descriptor limit.  Multiply the two to determine how much system
memory the user can consume using sockets.

This is why I view a lot ofthis work as quite pointless.  We already
have limits, but nobody wants to use them for performance reasons :-)
