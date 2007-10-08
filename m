From: David Miller <davem@davemloft.net>
Subject: Re: [NET] IPv6 oops bisected
Date: Sun, 07 Oct 2007 23:46:06 -0700 (PDT)
Message-ID: <20071007.234606.111182047.davem@davemloft.net>
References: <20071008061942.GA842@gondor.apana.org.au>
	<20071007.232302.78733656.davem@davemloft.net>
	<4709CF6F.60102@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, den@openvz.org
To: den@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752735AbXJHGqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:46:14 -0400
In-Reply-To: <4709CF6F.60102@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@sw.ru>
Date: Mon, 08 Oct 2007 10:34:23 +0400

> OK. I am installing Fedora 7 right now...

You don't need to install Fedora, just read the code! :-)

The bug is obvious and it's been explained thoroughly in this
thread.

When 'dev' is NULL in ip6_route_add() we need to figure out what
namespace and/or loopback device you want to use.

There is no reason to do an entire dist install to work on fixing this
bug, yikes!
