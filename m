From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][NET::SCHED]: cleanup qdisc_restart
Date: Mon, 14 Aug 2006 14:01:36 -0700 (PDT)
Message-ID: <20060814.140136.88477982.davem@davemloft.net>
References: <1155408186.5091.46.camel@jzny2>
	<44E1DD5F.4020603@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51096
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752066AbWHNVBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 17:01:35 -0400
To: shemminger@osdl.org
In-Reply-To: <44E1DD5F.4020603@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 15 Aug 2006 07:42:39 -0700

> Please don't change the values because some older drvers still return 1 
> rather
> than NETDEV_TX_BUSY

Unfortunately, this is probably very true.  So we indeed cannot
change the NETDEV_TX_BUSY value.
