From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 07 Aug 2009 21:03:56 -0400
Message-ID: <4A7CCEFC.7020308@myri.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>	<4A7C9A14.7070600@inria.fr> <20090807175112.a1f57407.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2008 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754533AbZHHBjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 21:39:35 -0400
In-Reply-To: <20090807175112.a1f57407.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:

> All sysfs local_cpus values are the same (00000000,000000ff),
> so yes they are also wrong.

How were you handling IRQ binding?  If local_cpus is wrong,
the irqbalance will not be able to make good decisions about
where to bind the NICs' IRQs.  Did you try manually binding
each NICs's interrupt to a separate CPU on the correct node?

Regards,

Drew
