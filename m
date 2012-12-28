From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 03/25] sja1000: don't use [delayed_]work_pending()
Date: Fri, 28 Dec 2012 16:40:52 -0500
Message-ID: <20121228214052.GD3062@mtj.dyndns.org>
References: <1356141435-17340-1-git-send-email-tj@kernel.org>
 <1356141435-17340-4-git-send-email-tj@kernel.org>
 <20121222.000111.1132195626602429566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, wg@grandegger.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121222.000111.1132195626602429566.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 22, 2012 at 12:01:11AM -0800, David Miller wrote:
> From: Tejun Heo <tj@kernel.org>
> Date: Fri, 21 Dec 2012 17:56:53 -0800
> 
> > There's no need to test whether a (delayed) work item in pending
> > before queueing, flushing or cancelling it.  Most uses are unnecessary
> > and quite a few of them are buggy.
> > 
> > Remove unnecessary pending tests from sja1000.  Only compile tested.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: Wolfgang Grandegger <wg@grandegger.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> > ---
> > Please let me know how this patch should be routed.  I can take it
> > through the workqueue tree if necessary.
> 
> I would suggest just taking it via the workqueue tree, thanks Tejun.

Applied to wq/for-3.9-cleanups w/ your Acked-by added.

Thanks.

-- 
tejun
