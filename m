From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible regression in HTB
Date: Thu, 09 Oct 2008 13:58:30 +0200
Message-ID: <48EDF1E6.3060306@trash.net>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <20081008072203.GJ22396@verge.net.au> <20081008080340.GE4174@ff.dom.local> <20081009005437.GA6342@verge.net.au> <20081009062145.GA4159@ff.dom.local> <20081009111836.GB28667@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48862 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319AbYJIL6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 07:58:34 -0400
In-Reply-To: <20081009111836.GB28667@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
>> It seems it's safer to use something below such magic number, and
>> generally 10% below hardware limit could be the rule.
> 
> That kind of rule would certainly solve this case,
> not it would be nice for such a rule not to be necessary.

It would be interesting to see if higher burst rates allow you
to use higher rates. Userspace automatically calculates the
bursts based on the timer frequency, which requires that the
timers actually reach that frequency during runtime. With high
packet rates that might not always be the case, so perhaps we
can do better by adding a few percent on top.
