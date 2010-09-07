From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] net/9p/trans_fd.c: Fix unsigned return type
Date: Mon, 06 Sep 2010 18:39:57 -0700 (PDT)
Message-ID: <20100906.183957.13763018.davem@davemloft.net>
References: <1283713226-8429-1-git-send-email-julia@diku.dk>
	<1283713226-8429-4-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756043Ab0IGBjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:39:40 -0400
In-Reply-To: <1283713226-8429-4-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun,  5 Sep 2010 21:00:21 +0200

> The function has an unsigned return type, but returns a negative constant
> to indicate an error condition.  The result of calling the function is
> always stored in a variable of type (signed) int, and thus unsigned can be
> dropped from the return type.
> 
> A sematic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
