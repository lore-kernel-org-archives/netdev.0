From: David Miller <davem@davemloft.net>
Subject: Re: tcp_slow_start_after_idle
Date: Wed, 14 Jun 2006 15:30:59 -0700 (PDT)
Message-ID: <20060614.153059.10907949.davem@davemloft.net>
References: <20060613.223538.24611602.davem@davemloft.net>
	<449042E0.4020409@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21471
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964883AbWFNWal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 18:30:41 -0400
To: zach.brown@oracle.com
In-Reply-To: <449042E0.4020409@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zach Brown <zach.brown@oracle.com>
Date: Wed, 14 Jun 2006 10:09:52 -0700

> Nice, thanks for the heads-up.  I'll pass the notice on to the guys who
> were asking about this in that thread.

Which Wall Street brokerage firm was it? :-)

That's basically who wants this stuff, people doing financial
transactions.  They seem to open up a connection, and just blast out
data periodically (with frequency > RTO, which is the whole problem)
and they want good latency results from that.
