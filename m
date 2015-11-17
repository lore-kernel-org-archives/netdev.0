From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-scm: Delete an unnecessary check before the
 function call "kfree"
Date: Tue, 17 Nov 2015 12:10:21 -0500 (EST)
Message-ID: <20151117.121021.367627373283927784.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<564B5937.1070707@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564B5937.1070707@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 17 Nov 2015 17:43:35 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 17 Nov 2015 17:37:22 +0100
> 
> The kfree() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

STOP submitting this crap, NOW!

I told you I won't review nor apply these patches any more.

And ever worse, this one is BUGGY.

We're testing p->fp so we know if we can safely dereference
it or not.

You're adding an OOPS to the kernel.

This is why these mindless mechanical transformations are not
only often a waste of time, they are dangerous as well.

I am silently rejecting from patchwork, immediately, any and all
patches you submit of this nature.
