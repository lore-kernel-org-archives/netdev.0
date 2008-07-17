From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 17 Jul 2008 14:37:53 -0700 (PDT)
Message-ID: <20080717.143753.250293973.davem@davemloft.net>
References: <12162854952457-git-send-email-jie.yang@atheros.com>
	<200807172204.15342.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jie.yang@atheros.com, jeff@garzik.org, yjwei@cn.fujitsu.com,
	rdreier@cisco.com, shemminger@vyatta.com, jcliburn@gmail.com,
	parag.warudkar@gmail.com, w@1wt.eu,
	oliver.schuster@schweigstill.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: m.kozlowski@tuxland.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754661AbYGQVhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 17:37:54 -0400
In-Reply-To: <200807172204.15342.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Date: Thu, 17 Jul 2008 22:04:14 +0200

> Hello,
> 
> > +#define SPEED_0		   0xffff
> > +#define SPEED_10           10
> > +#define SPEED_100          100
> > +#define SPEED_100          100
> 
> Small thing - double define for SPEED_100.
> 
> > +#define SPEED_1000         1000

And these are all entirely superfluous, since they are already defined
in linux/ethtool.h
