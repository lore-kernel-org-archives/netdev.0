From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 15:55:05 -0500 (EST)
Message-ID: <20120301.155505.674909686053535283.davem@davemloft.net>
References: <1330606237.27405.5.camel@megeve>
	<1330606775.2465.56.camel@edumazet-laptop>
	<4F4F7FFB.6010608@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rodrigo.moya@collabora.co.uk,
	David.Laight@ACULAB.COM, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: javier.martinez@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F4F7FFB.6010608@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Date: Thu, 01 Mar 2012 14:56:11 +0100

> We could use AF_INET multicast on a local machine but we need some
> ordering and control flow requirements that are not guaranteed on UDP
> multicast over IP. That's why we thought to add a new address family
> AF_MCAST.

None of this makes any sense to me.

Unless you have infinite amounts of memory you have to handle packet
drops, and the same things that handle packet drops on a protocol
level can handle out-of-order delivery too.

Stop reinventing the wheel, use facilities that exist already.
