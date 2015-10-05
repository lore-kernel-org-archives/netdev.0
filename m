From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] RDS: RDS-TCP perf enhancements
Date: Mon, 05 Oct 2015 03:35:47 -0700 (PDT)
Message-ID: <20151005.033547.905125073688788587.davem@davemloft.net>
References: <cover.1443636587.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	igor.maximov@oracle.com, santosh.shilimkar@oracle.com,
	sergei.shtylyov@cogentembedded.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1443636587.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 30 Sep 2015 16:54:06 -0400

> A 3-part patchset that (a) improves current RDS-TCP perf
> by 2X-3X and (b) refactors earlier robustness code for
> better observability/scaling.
> 
> Patch 1 is an enhancment of earlier robustness fixes 
> that had used separate sockets for client and server endpoints to
> resolve race conditions. It is possible to have an equivalent
> solution that does not use 2 sockets. The benefit of a
> single socket solution is that it results in more predictable
> and observable behavior for the underlying TCP pipe of an 
> RDS connection
> 
> Patches 2 and 3 are simple, straightforward perf bug fixes
> that align the RDS TCP socket with other parts of the kernel stack.
> 
> v2: fix kbuild-test-robot warnings, comments from  Sergei Shtylov
>     and Santosh Shilimkar. 

Series applied to net-next, thanks.
