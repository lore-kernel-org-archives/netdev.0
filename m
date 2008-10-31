From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 23:10:16 +0300
Message-ID: <20081031201016.GA4748@ioremap.net>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi> <20081031.005219.141937694.davem@davemloft.net> <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi> <20081031.025159.51432990.davem@davemloft.net> <490AE1CD.9040207@cosmosbay.com> <20081031125713.6c6923de@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	rjw@sisk.pl, mingo@elte.hu, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, efault@gmx.de, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:36184 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbYJaUKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 16:10:19 -0400
Content-Disposition: inline
In-Reply-To: <20081031125713.6c6923de@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 12:57:13PM -0700, Stephen Hemminger (shemminger@vyatta.com) wrote:
> Why bother with last_rx at all on loopback.  I have been thinking
> we should figure out a way to get rid of last_rx all together. It only
> seems to be used by bonding, and the bonding driver could do the calculation
> in its receive handling.

Not related to the regression: bug will be just papered out by this
changes. Having bonding on loopback is somewhat strange idea, but still
this kind of changes is an attempt to make a good play in the bad game:
this loopback-only optimization does not fix the problem.

-- 
	Evgeniy Polyakov
