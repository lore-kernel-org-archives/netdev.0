From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/tun.c: test for CAP_NET_ADMIN before
 attaching
Date: Fri, 29 Jul 2011 07:36:23 -0700 (PDT)
Message-ID: <20110729.073623.544936174715744280.davem@davemloft.net>
References: <20110729142808.GA25695@pintail.smokva.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: petar@smokva.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab1G2Ogc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:36:32 -0400
In-Reply-To: <20110729142808.GA25695@pintail.smokva.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petar Bogdanovic <petar@smokva.net>
Date: Fri, 29 Jul 2011 16:28:08 +0200

> The following change will test for CAP_NET_ADMIN before attaching, even
> if both tun->owner and tun->group equal -1.  The latter scenario can be
> reproduced with ip(8) from iproute2, when using `ip tuntap' without the
> `user' and `group' option.

Please read linux/Documentation/SubmittingPatches, for example you
need to provide a proper "Signed-off-by: " tag at the end of your
commit message.
