From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Sun, 21 Sep 2008 00:22:15 -0700 (PDT)
Message-ID: <20080921.002215.70489510.davem@davemloft.net>
References: <48B44768.3030208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lachlan.andrew@gmail.com
To: virtualphtn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751190AbYIUHW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 03:22:28 -0400
In-Reply-To: <48B44768.3030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Quetchenbach <virtualphtn@gmail.com>
Date: Tue, 26 Aug 2008 11:11:52 -0700

> This patch (applies to latest net-2.6) reduces the advertised value to
> that requested by the user as long as setsockopt() is called before
> connect() or accept(). This seems like the behavior that one would expect
> as well as that which is documented.
 ...
> Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>

I've applied this patch to net-next-2.6, thanks Tom.
