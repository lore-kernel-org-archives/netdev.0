From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Fri, 07 Sep 2007 19:04:15 -0400
Message-ID: <46E1D8EF.7010608@pobox.com>
References: <200708201704.11529.technoboy85@gmail.com> <200709061734.11170.technoboy85@gmail.com> <20070906153025.7cb71cb1.akpm@linux-foundation.org> <200709070121.42629.technoboy85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mips@linux-mips.org, ejka@imfi.kspu.ru,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@coreworks.de
To: Matteo Croce <technoboy85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47435 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbXIGXEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:04:40 -0400
In-Reply-To: <200709070121.42629.technoboy85@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matteo Croce wrote:
> Il Friday 07 September 2007 00:30:25 Andrew Morton ha scritto:
>>> On Thu, 6 Sep 2007 17:34:10 +0200 Matteo Croce <technoboy85@gmail.com> wrote:
>>> Driver for the cpmac 100M ethernet driver.
>>> It works fine disabling napi support, enabling it gives a kernel panic
>>> when the first IPv6 packet has to be forwarded.
>>> Other than that works fine.
>>>
>> I'm not too sure why I got cc'ed on this (and not on patches 1-6?) but
>> whatever.
> 
> I mailed every maintainer in the respective section in the file MAINTAINERS
> and you were in the "NETWORK DEVICE DRIVERS" section
> 
>> This patch introduces quite a number of basic coding-style mistakes. 
>> Please run it through scripts/checkpatch.pl and review the output.
> 
> Already done. I'm collecting other suggestions before committing

cool, I'll wait for the resend before reviewing, then.

As an author I understand that fixing up coding style / cosmetic stuff 
rather than "meat" is annoying.

But it is important to emphasize that a "clean" driver is what makes a 
good, thorough, effective review possible.

	Jeff


