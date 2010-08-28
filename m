From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: Eliminate kstrdup memory leak
Date: Fri, 27 Aug 2010 19:32:14 -0700 (PDT)
Message-ID: <20100827.193214.71098473.davem@davemloft.net>
References: <1282938463-26450-1-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52425
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016Ab0H1Cb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 22:31:58 -0400
In-Reply-To: <1282938463-26450-1-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Fri, 27 Aug 2010 21:47:43 +0200

> The string clone is only used as a temporary copy of the argument val
> within the while loop, and so it should be freed before leaving the
> function.  The call to strsep, however, modifies clone, so a pointer to the
> front of the string is kept in saved_clone, to make it possible to free it.
> 
> The sematic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied, thanks!
