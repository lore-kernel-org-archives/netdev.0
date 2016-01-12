From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH 17/53] perf test: Improve bp_signal
Date: Tue, 12 Jan 2016 10:21:29 +0100
Message-ID: <20160112092129.GA2187@krava.brq.redhat.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-18-git-send-email-wangnan0@huawei.com>
 <20160111213729.GI18367@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, linux-kernel@vger.kernel.org,
	pi3orama@163.com, lizefan@huawei.com, netdev@vger.kernel.org,
	davem@davemloft.net, Will Deacon <will.deacon@arm.com>,
	Jiri Olsa <jolsa@kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752629AbcALJVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 04:21:33 -0500
Content-Disposition: inline
In-Reply-To: <20160111213729.GI18367@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2016 at 06:37:29PM -0300, Arnaldo Carvalho de Melo wrote:
> Em Mon, Jan 11, 2016 at 01:48:08PM +0000, Wang Nan escreveu:
> > Will Deacon [1] has some question on patch [2]. This patch improves
> > test__bp_signal so we can test:
> > 
> >  1. A watchpoint and a breakpoint that fire on the same instruction
> >  2. Nested signals
> > 
> > Test result:
> > 
> >  On x86_64 and ARM64 (result are similar with patch [2] on ARM64):
> > 
> >  # ./perf test -v signal
> >  17: Test breakpoint overflow signal handler                  :
> >  --- start ---
> >  test child forked, pid 10213
> >  count1 1, count2 3, count3 2, overflow 3, overflows_2 3
> >  test child finished with 0
> >  ---- end ----
> >  Test breakpoint overflow signal handler: Ok
> > 
> > So at least 2 cases Will doubted are handled correctly.
> > 
> > [1] http://lkml.kernel.org/g/20160104165535.GI1616@arm.com
> > [2] http://lkml.kernel.org/g/1450921362-198371-1-git-send-email-wangnan0@huawei.com
> > 
> > Signed-off-by: Wang Nan <wangnan0@huawei.com>
> > Cc: Will Deacon <will.deacon@arm.com>
> 
> Will, are you ok with this one? Can I have an Acked-by or better,
> Tested-by for the AARCH64 base?
> 
> IIRC Jiri made some comment about this one?

I thought I acked this one.. all comments were addresses, so:

Acked-by: Jiri Olsa <jolsa@kernel.org>

thanks,
jirka
