From: David Miller <davem@davemloft.net>
Subject: Re: ss -p is much too slow
Date: Fri, 23 Jul 2010 12:48:19 -0700 (PDT)
Message-ID: <20100723.124819.246519789.davem@davemloft.net>
References: <AANLkTikd3VaSUa-pxzyi7_fND40vQ-L79X7yv19jj3y0@mail.gmail.com>
	<20100628.162139.59679342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: sphink@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751885Ab0GWTsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 15:48:04 -0400
In-Reply-To: <20100628.162139.59679342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 28 Jun 2010 16:21:39 -0700 (PDT)

> ss: Avoid quadradic complexity with '-p'
> 
> Scan the process list of open sockets once, and store in a hash
> table to be used by subsequent find_user() calls.
> 
> Reported-by: Steve Fink <sphink@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Stephen, please apply this, it fixes the quadratic behavior and
has been sitting for a month.

It's in patchwork, just check your todo list.

Thanks.
