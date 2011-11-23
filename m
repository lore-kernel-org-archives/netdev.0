From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 23 Nov 2011 18:44:25 -0500 (EST)
Message-ID: <20111123.184425.1412287327735765077.davem@davemloft.net>
References: <20111123150004.59be04eb36c480ec44edc9d5@canb.auug.org.au>
	<20111123120937.GB27968@hmsreliant.think-freely.org>
	<20111123150213.ed7257cb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111123150213.ed7257cb.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 23 Nov 2011 15:02:13 -0800

> Needs a thorough redo.  Please take a look at the other cgroup
> subsystem headers.  The basic pattern is
> 
> #ifdef CONFIG_FOO_CGROUP
> <definitions and declarations>
> #else
> <any needed stubs go here>
> #endif
> 
> And that's it.

I told Neil to put the stub in net/core/dev.c since that's the one and
only call site.
