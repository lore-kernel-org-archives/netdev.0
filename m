From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH ipsec] xfrm: use the right dev to fill xdst
Date: Tue, 09 Apr 2013 13:33:29 -0400 (EDT)
Message-ID: <20130409.133329.293030369317491509.davem@davemloft.net>
References: <20130409124735.GA21448@secunet.com>
	<20130409.132138.1712236757714558152.davem@davemloft.net>
	<CAEnQRZB4ESaVwgiTScQyTp=Yo16aUhuonMJS7KzfNbs3zRoLFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, nicolas.dichtel@6wind.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: daniel.baluta@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759682Ab3DIRdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 13:33:31 -0400
In-Reply-To: <CAEnQRZB4ESaVwgiTScQyTp=Yo16aUhuonMJS7KzfNbs3zRoLFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Baluta <daniel.baluta@gmail.com>
Date: Tue, 9 Apr 2013 20:31:30 +0300

> As I mentioned earlier in this thread we are using some custom
> kernel modules that create the interfaces.
> 
> It's likely that these interfaces, for memory saving purposes, to
> skip attaching ipv6 device information.

So this is not an upstream bug.
