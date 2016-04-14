From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: use __napi_schedule_irqoff()
Date: Wed, 13 Apr 2016 23:38:08 -0400 (EDT)
Message-ID: <20160413.233808.1037769899570190443.davem@davemloft.net>
References: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
	<5B66FA2B-6AAE-4FEB-B5FB-C5C9DF48FDB5@gmail.com>
	<1460179856.6473.482.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, pgynther@google.com,
	opendmb@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbcDNDiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 23:38:11 -0400
In-Reply-To: <1460179856.6473.482.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Apr 2016 22:30:56 -0700

> From: Florian Fainelli <f.fainelli@gmail.com>
> 
> bcmgenet_isr1() and bcmgenet_isr0() run in hard irq context,
> we do not need to block irq again.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
