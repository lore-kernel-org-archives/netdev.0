From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: CBQ broken in 2.6
Date: Fri, 29 Jan 2010 12:25:31 +0000
Message-ID: <1264767932.4412.7.camel@mare-infinitum.sigsegv.cx>
References: <20100128125317.GA8931@ff.dom.local>
	 <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
	 <20100128184519.GA3109@del.dom.local>
	 <1264708135.22027.13.camel@magrat.sigsegv.cx>
	 <1264714062.3380.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab2.miniserver.com ([89.200.136.192]:39842 "EHLO
	www.sigsegv.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579Ab0A2MZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 07:25:38 -0500
In-Reply-To: <1264714062.3380.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> > Thanks for all the help. 
> 
> I am using CBQ myself with recent kernels and never found it
> 'borrowing', could you post a copy of your rules, or better, a subset of
> them desmonstrating the problem ?

Actually after going through it several times and looking at the code
Jarek pointed out it doesn't. 

Just the stats are very confusing and precision is not particularly
great.

It says "borrowed" while actually it is the child which has borrowed
from this class, not the class itself borrowing. The class has been
borrowed from, not it itself borrowed. 

As nobody else has complained about the stats they should be probably
left as is according to the "least surprise" principle.

As far as the precision becoming worse over the last 15 or so minor
revision 2.6.9 to 2.6.26 that cannot be helped. On my hardware it was so
bad that I had it confused with not working at all at some point. I
ended up sticking aggressive RED leafs on the biggest "offenders" and
this has gotten my config to a working state for now. I am not happy
with it, but it is better than no QoS at all.

> 
> 
> 
> 
-- 
   Understanding is a three-edged sword:
            your side, their side, and the truth. --Kosh Naranek

A. R. Ivanov
E-mail:  anton.ivanov@kot-begemot.co.uk
WWW:     http://www.kot-begemot.co.uk/


