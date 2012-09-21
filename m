From: John Jolly <jjolly@suse.com>
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
Date: Fri, 21 Sep 2012 15:28:49 -0600
Message-ID: <20120921212849.GI14393@linux-tkdk.sfcn.org>
References: <20120920071134.GF14393@linux-tkdk.sfcn.org>
 <20120921.132045.951559071646755065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, venkat.x.venkatsubra@oracle.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120921.132045.951559071646755065.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2012 at 01:20:45PM -0400, David Miller wrote:
> From: John Jolly <jjolly@suse.com>
> Date: Thu, 20 Sep 2012 01:11:34 -0600
> 
> > Attempting an rds connection from the IP address of an IPoIB interface
> > to itself causes a kernel panic due to a BUG_ON() being triggered. Making
> > the test less strict allows rds-ping to work without crashing the machine.
> > 
> > A local unprivileged user could use this flaw to crash the sytem.
> 
> Please read Documentation/SubmittingPatches to learn how to properly
> submit a change, in particular your patch submission was missing a
> proper signoff.

Thanks for catching that. Resubmitting with proper signoff.

> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
