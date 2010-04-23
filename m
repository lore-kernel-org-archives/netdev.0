From: Patrick McHardy <kaber@trash.net>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 15:57:41 +0200
Message-ID: <4BD1A755.1020201@trash.net>
References: <1271941082.14501.189.camel@jdb-workstation>  <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>  <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop> <4BD17CF9.4020502@trash.net> <Pine.LNX.4.64.1004231440190.840@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58633 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083Ab0DWN5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 09:57:44 -0400
In-Reply-To: <Pine.LNX.4.64.1004231440190.840@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> On Fri, 23 Apr 2010, Patrick McHardy wrote:
> 
>> That sounds like a good idea. But lets what for Jesper's test results
>> before we start fixing this problem :)
> 
> I will first have time to perform the tests Monday or Tuesday.
> 
> BUT I have just noticed there seems to be a corrolation between
> conntrack early_drop and searches.  I have upload a new graph:
> 
>  http://people.netfilter.org/hawk/DDoS/2010-04-12__001/conntrack_early_drop002.png

I guess that's somewhat expected when your conntrack table is full
and all you're seeing is new connection setup attempts.

First you have a search for an existing conntrack, then it attempts
to create a new one and tries to early_drop and old one.
