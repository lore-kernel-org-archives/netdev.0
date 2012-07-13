From: David Miller <davem@davemloft.net>
Subject: Re: [DANGER 8/7]: ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 12 Jul 2012 18:06:32 -0700 (PDT)
Message-ID: <20120712.180632.2257789590224563114.davem@davemloft.net>
References: <20120712.104758.253504708560401123.davem@davemloft.net>
	<CAGK4HS_-fQYnmcbBwEE=JywzAO7_nnE8QAOCXk3-WQOjCimPiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758224Ab2GMBGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 21:06:33 -0400
In-Reply-To: <CAGK4HS_-fQYnmcbBwEE=JywzAO7_nnE8QAOCXk3-WQOjCimPiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Thu, 12 Jul 2012 17:52:54 -0700

> ip_rcv_finish() eventually calls ip_route_input_slow() wherein
> fib_lookup() initially returns a res.type of RTN_UNICAST (why not
> RTN_LOCAL?).

Strange, since only this specific patch causes the problem there must
be some issue with the size of struct fib_info or something like that
triggering the problem.  Something might be corrupted in the nexthops.

I wonder if there is some uninitialized data somewhere, or something
silly like that.
