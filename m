From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Thu, 10 Apr 2008 21:17:46 +0900 (JST)
Message-ID: <20080410.211746.35006447.yoshfuji@linux-ipv6.org>
References: <20080410.015118.103465510.davem@davemloft.net>
	<20080410.180148.120248426.yoshfuji@linux-ipv6.org>
	<20080410.035618.217931997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32927 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbYDJMQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 08:16:05 -0400
In-Reply-To: <20080410.035618.217931997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080410.035618.217931997.davem@davemloft.net> (at Thu, 10 Apr 2008 03:56:18 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> Branch prediction fares very poorly in such cases, and
> therefore it is better to mispredict one branch over
> all the data items in the same cache line than any one
> of several such branches.  The above new sequence gets
> emitted by the compiler as several integer operations and
> one branch.  As long as all the data items are in the
> same cacheline, this is optimal.

Okay, thanks.

--yoshfuji
