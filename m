From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: addrconf: drop ieee802154 specific
 things
Date: Mon, 14 Dec 2015 16:11:04 -0500 (EST)
Message-ID: <20151214.161104.51809961792932420.davem@davemloft.net>
References: <1450122922-3174-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wpan@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932371AbbLNVLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:11:10 -0500
In-Reply-To: <1450122922-3174-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Mon, 14 Dec 2015 20:55:22 +0100

> This patch removes ARPHRD_IEEE802154 from addrconf handling. In the
> earlier days of 802.15.4 6LoWPAN, the interface type was ARPHRD_IEEE802154
> which introduced several issues, because 802.15.4 interfaces used the
> same type.
> 
> Since commit 965e613d299c ("ieee802154: 6lowpan: fix ARPHRD to
> ARPHRD_6LOWPAN") we use ARPHRD_6LOWPAN for 6LoWPAN interfaces. This
> patch will remove ARPHRD_IEEE802154 which is currently deadcode, because
> ARPHRD_IEEE802154 doesn't reach the minimum 1280 MTU of IPv6.
> 
> Also we use 6LoWPAN EUI64 specific defines instead using link-layer
> constanst from 802.15.4 link-layer header.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Applied, thank you.
