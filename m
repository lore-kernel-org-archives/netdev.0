From: David Miller <davem@davemloft.net>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 18:35:20 -0400 (EDT)
Message-ID: <20120517.183520.1377234710702090939.davem@davemloft.net>
References: <20120517222431.GT14498@1wt.eu>
	<20120517.182545.91312407467980757.davem@davemloft.net>
	<20120517223028.GV14498@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967768Ab2EQWfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 18:35:43 -0400
In-Reply-To: <20120517223028.GV14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 18 May 2012 00:30:28 +0200

> On Thu, May 17, 2012 at 06:25:45PM -0400, David Miller wrote:
>> From: Willy Tarreau <w@1wt.eu>
>> Date: Fri, 18 May 2012 00:24:31 +0200
>> 
>> > On Fri, May 18, 2012 at 12:22:31AM +0200, Eric Dumazet wrote:
>> >> Hmm... I believe I prefer your prior patch ( the one I Acked)
>> > 
>> > I too, less changes are better :-)
>> 
>> And I think that's the one I'm going to apply after I audit this
>> code a little bit myself.
>> 
>> Thanks!
> 
> Sorry for the double mail, I didn't know if you were following the thread
> when I forwarded it to you.

No problem.

BTW, this issue goes back all the way to the original implementation
of do_tcp_sendpages().
