From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [net/core] move dev_mc_discard from dev_mcast.c to
 dev.c
Date: Wed, 18 Jul 2007 03:03:06 -0700 (PDT)
Message-ID: <20070718.030306.50591269.davem@davemloft.net>
References: <11847264651509-git-send-email-crquan@gmail.com>
	<20070718.021107.40833440.davem@davemloft.net>
	<91b13c310707180259v547ba2b3wc901102d35760a50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754746AbXGRKDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:03:07 -0400
In-Reply-To: <91b13c310707180259v547ba2b3wc901102d35760a50@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "rae l" <crquan@gmail.com>
Date: Wed, 18 Jul 2007 17:59:52 +0800

> And then the dev_mcast.c is now only 256 lines long(versus dev.c 4052 lines),
> just left a few multicast related functions definition and "dev_mcast"
> procfs code,
> I have an idea to merge all code dev_mcast.c into dev.c, that would:
> 
> - remove two functions (__dev_addr_delete, __dev_set_rx_mode) from netdevice.h,
>   and then tag them static,
>   those two are also defined in dev.c and only called from dev_mcast.c,
> 
> - reducing one file would benefit the compilation process.
> 
> All in one word, I don't think the single file dev_mcast.c is needed anymore.

Agreed.
