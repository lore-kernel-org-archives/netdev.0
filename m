From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tc35815: move free after the dereference
Date: Mon, 24 Apr 2017 12:38:29 -0400 (EDT)
Message-ID: <20170424.123829.2173782188245590052.davem@davemloft.net>
References: <20170421104937.7sxibmruc6pvp26p@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anemo@mba.ocn.ne.jp, tremyfr@gmail.com, jarod@redhat.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170421104937.7sxibmruc6pvp26p@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 21 Apr 2017 13:49:37 +0300

> We dereference "skb" to get "skb->len" so we should probably do that
> step before freeing the skb.
> 
> Fixes: eea221ce4880 ("tc35815 driver update (take 2)")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
