From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 06:48:31 -0700
Message-ID: <1445608111.22974.146.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
	  <201510231320.t9NDKZv9017488@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35222 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbbJWNsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 09:48:36 -0400
Received: by pasz6 with SMTP id z6so119097065pas.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 06:48:35 -0700 (PDT)
In-Reply-To: <201510231320.t9NDKZv9017488@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 15:20 +0200, Casper.Dik@oracle.com wrote:

> This point was not about a 10M sockets server but in general...
> 

Hey, we do not design the OS only for handling desktop workloads.

If netstat does not work on this typical server workload, then it is a
joke.

> Solaris has had such an option too, but that wasn't the point.  You really 
> don't want to know which application is doing this?


Apparently nobody had this need before you asked.

My point is that instead of carrying ~30 years of legacy, we would
better design the system properly so that we can _use_ it in all
situations.

ps used to open /dev/kmem a long time ago.

fuser and similar commands having to know system internals are really
hacks.
