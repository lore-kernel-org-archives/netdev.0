From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 03/27] drivers/net: fix sparse warning: returning
 void-valued expression
Date: Fri, 26 Dec 2008 11:59:21 -0800
Message-ID: <20081226115921.bb094c58.rdunlap@xenotime.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
	<20081225.161740.10052019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:53880 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752373AbYLZT72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Dec 2008 14:59:28 -0500
Received: from dragon ([71.117.247.66]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 26 Dec 2008 11:59:26 -0800
In-Reply-To: <20081225.161740.10052019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Dec 2008 16:17:40 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Hannes Eder <hannes@hanneseder.net>
> Date: Mon, 22 Dec 2008 20:15:17 +0100
> 
> > Fix this sparse warning:
> > 
> >   drivers/net/niu.c:8850:2: warning: returning void-valued expression
> > 
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> 
> Can we just fix sparse not to generate this warning?  It's
> marginal, at best.  C++ even explicitly defines this as valid
> and last time I brought this up Linus even agreed.

Ack, I discussed it with him also and he thought that
they were just fine as they were...

> The types match, the function returns void and it is returning a void,
> what is the problem?


-- 
~Randy
