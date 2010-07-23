From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ss -p is much too slow
Date: Fri, 23 Jul 2010 13:01:25 -0700
Message-ID: <20100723130125.787c7ddb@nehalam>
References: <AANLkTikd3VaSUa-pxzyi7_fND40vQ-L79X7yv19jj3y0@mail.gmail.com>
	<20100628.162139.59679342.davem@davemloft.net>
	<20100723.124819.246519789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sphink@gmail.com, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39042 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758203Ab0GWUB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 16:01:27 -0400
In-Reply-To: <20100723.124819.246519789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Jul 2010 12:48:19 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Mon, 28 Jun 2010 16:21:39 -0700 (PDT)
> 
> > ss: Avoid quadradic complexity with '-p'
> > 
> > Scan the process list of open sockets once, and store in a hash
> > table to be used by subsequent find_user() calls.
> > 
> > Reported-by: Steve Fink <sphink@gmail.com>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Stephen, please apply this, it fixes the quadratic behavior and
> has been sitting for a month.
> 
> It's in patchwork, just check your todo list.
> 

I saw it but wanted to work out a more general solution,
will apply it next week if mine doesn't work.
