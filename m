From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 10:26:21 -0700
Message-ID: <4905F9BD.100@hp.com>
References: <1224905848.5161.27.camel@marge.simson.net>	<20081024.221653.23695396.davem@davemloft.net>	<1224914333.3822.18.camel@marge.simson.net>	<20081025.001940.251852864.davem@davemloft.net> <1224919985.5373.10.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753172AbYJ0R0n@vger.kernel.org>
In-Reply-To: <1224919985.5373.10.camel@marge.simson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Galbraith wrote:
> That's exactly what I've been trying to look into, but combined with
> netperf.  The thing is an incredibly twisted maze of _this_ affects
> _that_... sometimes involving magic and/or mythical creatures.

I cannot guarantee it will help, but the global -T option to pin netperf 
or netserver to a specific CPU might help cut-down the variables.

FWIW netperf top of trunk omni tests can now also determine and report 
the state of SELinux.  They also have code to accept or generate their 
own RFC4122-esque UUID.  Define some connical tests and then ever closer 
to just needing some database-fu and automagic testing I suppose... 
things I do not presently posess but am curious enough to follow some 
pointers.

happy benchmarking,

rick jones
