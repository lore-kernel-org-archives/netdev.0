From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 18:08:40 -0400
Message-ID: <20090807180840.b27ce794.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CA24E.4080503@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, gallatin@myri.com
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:36675 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752944AbZHGWIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 18:08:40 -0400
In-Reply-To: <4A7CA24E.4080503@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Aug 2009, Brice Goglin wrote:

> Bill Fink wrote:
> >> I've seen some cases in the past where numa_node was always 0 on
> >> quad-Opteron machines with a PCI bus on node 1. IIRC it got fixed in
> >> later kernels thanks to patches from Yinghai Lu (CC'ed).
> >
> > By later kernels do you mean 2.6.30 or 2.6.31?
> 
> No, I meant "later than when the problem occured". I was using 2.6.22 at
> this point and the problem was fixed somewhere around 2.6.25.

OK.  The tests were run on a 2.6.29.6 kernel so presumably should
have included the fix you mentioned.

> >> Is the corresponding local_cpus sysfs file wrong as well ?
> >
> > All sysfs local_cpus values are the same (00000000,000000ff),
> > so yes they are also wrong.
> 
> And hyperthreading is enabled, right?

No, hyperthreading is disabled.  It's a dual quad-core system so there
are a total of 8 cores, 4 on NUMA node 0 and 4 on NUMA node2.

						-Thanks

						-Bill
