From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] drivers/atm/firestream.c: Fix unsigned return type
Date: Mon, 06 Sep 2010 18:40:07 -0700 (PDT)
Message-ID: <20100906.184007.58449609.davem@davemloft.net>
References: <1283713226-8429-1-git-send-email-julia@diku.dk>
	<1283713226-8429-6-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283713226-8429-6-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>
Date: Sun,  5 Sep 2010 21:00:23 +0200

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
