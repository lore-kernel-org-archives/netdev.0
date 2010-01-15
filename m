From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Thu, 14 Jan 2010 16:51:42 -0800 (PST)
Message-ID: <20100114.165142.163322281.davem@davemloft.net>
References: <20100112.121607.39835310.davem@davemloft.net>
	<201001141250.27287.schmto@hrz.tu-chemnitz.de>
	<4B4F132B.7020001@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655Ab0AOAvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 19:51:33 -0500
In-Reply-To: <4B4F132B.7020001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Jan 2010 13:50:51 +0100

> Problem is, you might need many sets of counters...

Why nobody has suggested using existing kernel facilities for this is
beyond me.

We have a diffserv packet scheduler queueing discipline, so you can
classify traffic arbitrarily based upon the diffserv bits in the
packet and then shape them using that classification into different
packet scheduler queues.

Simply attach those child queues to that default pfifo qdisc, nothing
fancy.

Then you can dump the queue stats using 'tc'.
