From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Tue, 03 Jun 2008 22:05:32 -0500
Message-ID: <4846067C.1020807@sngx.net>
References: <482DA5B6.1020606@sngx.net>	<482DB46A.8020103@cosmosbay.com>	<482EF192.4070707@sngx.net>	<482F5113.5090703@cosmosbay.com>	<482F610D.2080108@sngx.net>	<20080518003104.GK28241@solarflare.com>	<482FBA09.80201@sngx.net>	<483E0AAE.2020107@sngx.net>	<20080528221118.63da4092.akpm@linux-foundation.org>	<483EA2D1.8050603@sngx.net>	<20080529154525.3916c7b5@core>	<20080530151250.b44a119a.billfink@mindspring.com>	<20080531131143.516ca56e@core>	<20080531195702.0b879dd1.billfink@mindspring.com>	<48437C25.7080400@gdt.id.au>	<20080602121007.1e81cf05.billfink@mindspring.com>	<48453909.4000301@sngx.net> <20080603154602.01b10adb@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl093-193-175.stl1.dsl.speakeasy.net ([66.93.193.175]:58058
	"EHLO hades.sngx.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751652AbYFDDDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 23:03:33 -0400
In-Reply-To: <20080603154602.01b10adb@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I used to work in a large ISP - it was a huge concern then and was
> enforced and managed by the less effective 'do you like your kneecaps'
> approach to permissions.

I work at a large ISP now, and you're absolutely right.  You don't just go 
around resetting interface counters on backbone routers for the hell of it, 
and we never do it without customer permission while troubleshooting an 
issue with a connection, that is why I said I thought it was a non-argument.
There seems to be an irrational fear of counter-based anarchy here.

> Its basically impossible to write a correct non-racy application which
> zeros kernel statistics and then measures the change, because you cannot
> know another application did the same while you were running.
> 
> This is the most basic and blindingly obvious stuff. You should not be
> able to zero the kernel stats just because you can't work perl.

I've already said I'd drop the issue 4+ days ago, and that I'd be more
than happy to do it in userland as you suggested, my point was simply that
adding it to only one userland tool will lead to inconsistencies.  It is not
an issue of being able to "work perl" or not.
