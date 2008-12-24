From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while
 a compound statement
Date: Tue, 23 Dec 2008 18:10:27 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0812231808030.3535@localhost.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net> <20081222191507.11807.50794.stgit@vmbox.hanneseder.net> <m3hc4voo2a.fsf@maximus.localdomain> <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com> <m3ocz2ua3w.fsf@maximus.localdomain>
 <1230053186.1447.9.camel@brick> <m3k59qssix.fsf@maximus.localdomain> <alpine.LFD.2.00.0812231008350.3535@localhost.localdomain> <m3hc4usco9.fsf@maximus.localdomain> <alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
 <m3myemqqgp.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	=?ISO-8859-15?Q?H=E5kon_L=F8vdal?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49191 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbYLXCKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 21:10:35 -0500
In-Reply-To: <m3myemqqgp.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 24 Dec 2008, Krzysztof Halasa wrote:
> 
> People learn, or should, through the life :-)

Sure. But you should learn about the things that matter - not learn to 
avoid the stupid pitfalls that come from confusingly doing things so that 
they visually look similar even when they do different things.

So don't make people learn by putting traps in their face. That just 
wastes everybodys time.

> I'm not sure being common or less common does matter here much.
> 
> OTOH I think it's pretty common. Approx as common as while (x) y is,
> isn't it?

I doubt it. It certainly wasn't in the kernel. When we added the sparse 
warning, I think we got a couple of hits. 

Anyway,  not worth discussing. The fact is, the kernel does not accept do 
while without braces. I told you why. You can ignore it. I'll ignore you.

		Linus
