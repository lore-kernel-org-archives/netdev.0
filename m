From: David Miller <davem@davemloft.net>
Subject: Re: netperf and endianness
Date: Thu, 07 Jun 2012 18:20:38 -0700 (PDT)
Message-ID: <20120607.182038.1630334891753669027.davem@davemloft.net>
References: <20120607.180948.471478622905736125.davem@davemloft.net>
	<4FD1525E.5020707@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759714Ab2FHBUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 21:20:39 -0400
In-Reply-To: <4FD1525E.5020707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 07 Jun 2012 18:16:14 -0700

> netperf sends things in network byte order.  It is all burried in
> send/recv_request and send/recv_response (in src/netlib.c).

Aha, I was grepping for things like ENDIAN when I should have
grepped for htonl() :-)

> Over the years I've run netperf between different endian systems
> with success. Chances are good that there is a netperf version
> mismatch between the sides - at least 99 times out of 10 that is
> what is happening when netperf doesn't work (other than with
> firewalls in place).

Indeed, you are right.  I was trying to speak to 2.4.4 using
2.5.0 :-)

Thanks!
