From: David Miller <davem@davemloft.net>
Subject: Re: [patch] xen-netback: double free on unload
Date: Mon, 24 Jun 2013 00:26:07 -0700 (PDT)
Message-ID: <20130624.002607.1816906327683052502.davem@davemloft.net>
References: <20130621062008.GA10873@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130621062008.GA10873@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 21 Jun 2013 09:20:08 +0300

> There is a typo here, "i" vs "j", so we would crash on module_exit().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Please always explicitly state the tree for which a patch is
applicable.

Here I figured it out by trial an error, trying to apply it
to 'net' (where it failed) and then 'net-next' (where it
applied cleanly).

I should never have to play patch monkey games like that, you
need to tell me where a patch is targetted.

Thanks.
