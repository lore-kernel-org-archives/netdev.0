From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] neighbour cache statistics like rt_stat
Date: Mon, 27 Sep 2004 12:21:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927122136.7016b2c1.davem@davemloft.net>
References: <20040927093613.GH3236@sunbeam.de.gnumonks.org>
	<20040927162334.GV3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040927162334.GV3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 18:23:34 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> On Mon, Sep 27, 2004 at 11:36:13AM +0200, Harald Welte wrote:
> > The patch below (on top of davem's recent 6-patch set and 4-patch-set up
> > to diff4) adds rt_stat like statistics to the neighbour cache core.
> 
> I've now updated the patch.
> 
> Changes:
> 	- more statistics (lookups, destroy, periodic_gc_runs)
> 	- add template line to top of file

I'm generally very happy with these changes, but two things:

1) Please update the patch since I replaced "diff4" with
   a patch simply removing the INCOMPLETE checks from neigh_forced_gc()

2) I'd recommend using unsigned long for all the statistics.

Thanks.
