From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bridge: simplify br_getlink() a bit
Date: Sun, 25 Jan 2015 23:33:16 -0800 (PST)
Message-ID: <20150125.233316.1272794874104313977.davem@davemloft.net>
References: <20150121092235.GA19206@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150121092235.GA19206@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 21 Jan 2015 12:22:35 +0300

> Static checkers complain that we should maybe set "ret" before we do the
> "goto out;".  They interpret the NULL return from br_port_get_rtnl() as
> a failure and forgetting to set the error code is a common bug in this
> situation.
> 
> The code is confusing but it's actually correct.  We are returning zero
> deliberately.  Let's re-write it a bit to be more clear.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks.
