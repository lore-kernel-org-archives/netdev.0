From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max
 timeout before a TCP connection is aborted
Date: Sun, 29 Aug 2010 21:19:54 -0700 (PDT)
Message-ID: <20100829.211954.232753860.davem@davemloft.net>
References: <1282972408-19164-1-git-send-email-hkchu@google.com>
	<20100828.161320.245404727.davem@davemloft.net>
	<AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33524
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751014Ab0H3ETi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 00:19:38 -0400
In-Reply-To: <AANLkTimW_7a9=yK4po9FshH0i0LT-MZF+fysGRvgT3jG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Sun, 29 Aug 2010 17:23:05 -0700

> Personally I think as an API, it's easier for an application to
> grasp the concept of a time quantity than # of
> retransmissions. (E.g., how will an app determine it needs 10
> retries vs 20 retries?)

Conversely how can the user grasp how many actual attempts will
be made if backoff is employed?

It's very easy to under-cap the number of actual packet send
attempts that will be made specifying just a timeout, in the
presence of backoff.
