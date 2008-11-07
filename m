From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 7 Nov 2008 09:53:18 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
 <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
 <20081105.151015.206163697.davem@davemloft.net>
 <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44058 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbYKGHxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:53:20 -0500
In-Reply-To: <alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Nov 2008, Mikael Abrahamsson wrote:

> On Wed, 5 Nov 2008, David Miller wrote:
> 
> > This kind of thinking just perpetuates the problem forever.
> 
> It's like the TCP option order "bug", where some devices would drop the
> packets because of buggy implementations, that was changed in Linux to work
> around others buggy code, and I see "ECN blackhole detection" as a similar
> measure.

That is entirely bogus claim! The different ordering of options cost us 
nothing, while disabling ECN certainly has an innumerable cost both in 
performance and in nobody taking the initiative which makes the situation 
worse for everybody.

And about somebody earlier claiming that they'll get an impressions that 
Linux stack is broken (if such people even know that there's some network 
stack in Linux :-))... I'm rather sure those isp supports etc. put a blaim 
on us anyway even when loads of counterproof would exists because it's 
just cheaper to do nothing and blaim linux instead. Also some claims 
asserted by incompetent people easily start to live among random forums; 
an example from the previous incident: "since disabling timestamps helps, 
it must be that timestamps are broken" (and somebody even "more clueful" 
added that they got enabled for 2.6.27?!?), needless to say, neither 
holds.


-- 
 i.
