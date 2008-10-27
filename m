From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 20:11:30 +0100
Message-ID: <1225134690.4942.11.camel@marge.simson.net>
References: <1224905848.5161.27.camel@marge.simson.net>
	 <20081024.221653.23695396.davem@davemloft.net>
	 <1224914333.3822.18.camel@marge.simson.net>
	 <20081025.001940.251852864.davem@davemloft.net>
	 <1224919985.5373.10.camel@marge.simson.net>  <4905F9BD.100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:36073 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751407AbYJ0TLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 15:11:39 -0400
In-Reply-To: <4905F9BD.100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 10:26 -0700, Rick Jones wrote:
> Mike Galbraith wrote:
> > That's exactly what I've been trying to look into, but combined with
> > netperf.  The thing is an incredibly twisted maze of _this_ affects
> > _that_... sometimes involving magic and/or mythical creatures.
> 
> I cannot guarantee it will help, but the global -T option to pin netperf 
> or netserver to a specific CPU might help cut-down the variables.

Yup, and how.  Early on, the other variables drove me bat-shit frigging
_nuts_.  I eventually selected a UP config to test _because_ those other
variables combined with SMP overhead and config options drove crazy ;-) 

> FWIW netperf top of trunk omni tests can now also determine and report 
> the state of SELinux.  They also have code to accept or generate their 
> own RFC4122-esque UUID.  Define some connical tests and then ever closer 
> to just needing some database-fu and automagic testing I suppose... 
> things I do not presently posess but am curious enough to follow some 
> pointers.

Hrm. I'm going to have to save that, and parse a few times. (usual)

> happy benchmarking,

Not really, but I can't seem to give up ;-)

	-Mike

