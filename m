From: David Miller <davem@davemloft.net>
Subject: Re: High ksoftirq CPU load, high latency, __xfrm4_find_bundle
 likely culprit?
Date: Mon, 12 Mar 2012 12:51:47 -0700 (PDT)
Message-ID: <20120312.125147.1873592382305681577.davem@davemloft.net>
References: <4F5E1B4B.2070807@allenta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: robe@allenta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50592 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878Ab2CLTvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 15:51:51 -0400
In-Reply-To: <4F5E1B4B.2070807@allenta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roberto Suarez Soto <robe@allenta.com>
Date: Mon, 12 Mar 2012 16:50:35 +0100

> 	we've got a load problem in one of our IPSec gateways, running
> 	openswan 1:2.6.28+dfsg-5+squeeze1 and kernel 2.6.32-5-686-bigmem
> 	(Debian Squeeze). The symptoms are:

We had bugs where IPSEC routes weren't cached properly, and these were fixed
after 2.6.32 for sure.
