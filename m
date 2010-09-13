From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ppp: potential NULL dereference in ppp_mp_explode()
Date: Mon, 13 Sep 2010 12:45:30 -0700 (PDT)
Message-ID: <20100913.124530.115933711.davem@davemloft.net>
References: <20100910115809.GF5959@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, simon@fire.lp0.eu, ben@netservers.co.uk,
	shemminger@vyatta.com, lsorense@csclub.uwaterloo.ca,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20100910115809.GF5959@bicker>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 10 Sep 2010 13:58:10 +0200

> Smatch complains because we check whether "pch->chan" is NULL and then
> dereference it unconditionally on the next line.  Partly the reason this
> bug was introduced is because code was too complicated.  I've simplified
> it a little.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> Compile tested only.  Perhaps it would be better to set pch->speed to
> zero?  The comments say that zero implies the speed hasn't been set.

I think how you've fixed it is OK, actually this whole MP rewrite
could use some more auditing :-)

Applied, thanks Dan.
