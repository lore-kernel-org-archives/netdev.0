From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: Feature request: "inverted" ping -a (beep on failure)
Date: Fri, 15 Apr 2011 13:14:04 -0700
Message-ID: <20110415131404.bad26a5a.rdunlap@xenotime.net>
References: <201104152135.33171@tux.boltz.de.vu>
	<20110415124937.6e746646.rdunlap@xenotime.net>
	<201104152211.46180@tux.boltz.de.vu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Boltz <netdev-vger-kernel.org@cboltz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy1-pub.bluehost.com ([66.147.249.253]:53272 "HELO
	oproxy1-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754025Ab1DOUOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:14:08 -0400
In-Reply-To: <201104152211.46180@tux.boltz.de.vu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011 22:11:45 +0200 Christian Boltz wrote:

> Hello,
> 
> Am Freitag, 15. April 2011 schrieb Randy Dunlap:
> > On Fri, 15 Apr 2011 21:35:32 +0200 Christian Boltz wrote:
> > > I'd like to have the exact opposite of it: beep when pinging fails.
> [...]
> > Couldn't you look for exit code (status) 1 and then do a bell/beep
> > (or play a sound file :)?
> 
> That would require that I know in advance when exactly the server is 
> unreachable - but in this case, I wouldn't need to ping it ;-)

I didn't follow that, but it's OK.

> To have this working, ping would need an option "exit on error", which 
> it doesn't have AFAIK.

'man ping' discusses exit status codes:

       If  ping  does  not  receive any reply packets at all it will exit with
       code 1. If a packet count and deadline are both  specified,  and  fewer
       than  count  packets are received by the time the deadline has arrived,
       it will also exit with code 1.  On other error it exits  with  code  2.
       Otherwise  it exits with code 0. This makes it possible to use the exit
       code to see if a host is alive or not.


> A workaround is to run ping -c1 in a loop:
> 
> while true ; do       If  ping  does  not  receive any reply packets at all it will exit with
       code 1. If a packet count and deadline are both  specified,  and  fewer
       than  count  packets are received by the time the deadline has arrived,
       it will also exit with code 1.  On other error it exits  with  code  2.
       Otherwise  it exits with code 0. This makes it possible to use the exit
       code to see if a host is alive or not.
>     ping -c1 $server || beep
>     sleep 1
> done
> 
> but I'd prefer to have something like this directly in ping ;-)
> 
> > Or do you want ping to beep and then continue running?
> 
> Yes, that's exactly what I want.


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
