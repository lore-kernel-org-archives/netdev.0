From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Tue, 3 Jun 2008 15:46:02 +0100
Message-ID: <20080603154602.01b10adb@core>
References: <482DA5B6.1020606@sngx.net>
	<482DB46A.8020103@cosmosbay.com>
	<482EF192.4070707@sngx.net>
	<482F5113.5090703@cosmosbay.com>
	<482F610D.2080108@sngx.net>
	<20080518003104.GK28241@solarflare.com>
	<482FBA09.80201@sngx.net>
	<483E0AAE.2020107@sngx.net>
	<20080528221118.63da4092.akpm@linux-foundation.org>
	<483EA2D1.8050603@sngx.net>
	<20080529154525.3916c7b5@core>
	<20080530151250.b44a119a.billfink@mindspring.com>
	<20080531131143.516ca56e@core>
	<20080531195702.0b879dd1.billfink@mindspring.com>
	<48437C25.7080400@gdt.id.au>
	<20080602121007.1e81cf05.billfink@mindspring.com>
	<48453909.4000301@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756942AbYFCPGW@vger.kernel.org>
In-Reply-To: <48453909.4000301@sngx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Also, I'd like to point out that the "stepping on other peoples toes" 
> argument is a bogus one, since most major network vendors include this 
> ability, and it's not exactly a concern now.

I used to work in a large ISP - it was a huge concern then and was
enforced and managed by the less effective 'do you like your kneecaps'
approach to permissions.

Its basically impossible to write a correct non-racy application which
zeros kernel statistics and then measures the change, because you cannot
know another application did the same while you were running.

This is the most basic and blindingly obvious stuff. You should not be
able to zero the kernel stats just because you can't work perl.

Alan
