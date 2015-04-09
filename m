From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Thu, 09 Apr 2015 08:08:29 -0700
Message-ID: <1428592109.25985.249.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
	 <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>
	 <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>
	 <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.LSU.2.20.1504091127310.24030@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35826 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbbDIPIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 11:08:31 -0400
Received: by iggg4 with SMTP id g4so69084118igg.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 08:08:31 -0700 (PDT)
In-Reply-To: <alpine.LSU.2.20.1504091127310.24030@nerf40.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 12:26 +0200, Jan Engelhardt wrote:
> On Thursday 2015-04-09 11:24, Eric Dumazet wrote:
> >> I was finally able to reproduce it reliably, and with just one 
> >> machine/kernel instance (and a number of containers of course).
> >> 
> >> I have uploaded the script mix to
> >> 	http://inai.de/files/tso-1.tar.xz
> >> There is a demo screencast at
> >> 	http://inai.de/files/tso-1.mkv
> >
> >Thanks for providing these scripts, but they do not work on my host
> >running latest net-next
> >
> >Basic IP routing seems not properly enabled, as even ping does not work
> >to reach 10.10.23.23
> 
> Since I have net.ipv4.conf.all.forwarding,net.ipv4.ip_forward=1
> this probably got inherited into the containers, so I did not
> write it down into the scripts.
> Enable it :)

The thing is : It is enabled.

> 
> >Have you tried net-next as well ?
> 
> I have now - a quick test yields no problem. Next I will do a reverse 
> bisect just for the fun.

Cool ;)
