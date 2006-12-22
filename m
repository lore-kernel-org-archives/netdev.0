From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Netchannels take19] new netchannel release.
Date: Fri, 22 Dec 2006 11:28:46 +0300
Message-ID: <20061222082846.GC4397@2ka.mipt.ru>
References: <20061220151245.GA19335@2ka.mipt.ru> <20061221163625.GC10845@2ka.mipt.ru> <200612220140.33732.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45992 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945980AbWLVI3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 03:29:16 -0500
To: Hans Henrik Happe <hhh@imada.sdu.dk>
Content-Disposition: inline
In-Reply-To: <200612220140.33732.hhh@imada.sdu.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 22, 2006 at 01:40:33AM +0100, Hans Henrik Happe (hhh@imada.sdu.dk) wrote:
> > Code is in development state, but I would like to hear comments about
> > overall design, features, usefullness for the kernel and get feedback on
> > kernel side.
> 
> I follow your work with great interest, even though my kernel coding 
> experience isn't great. When I get the time I would like to actually try it 
> out and provide some feedback.
> 
> For now I only follow your progress by reading your web page to get the big 
> picture. I must admit it is not easy to get the overall picture from reading 
> that, because it is mostly about small details. I think you would get a lot 
> more enthusiasm from people, if you described your work top-down. Much of the 
> work is about new interfaces and it would be very helpfull with detailed 
> descriptions of these. 
> 
> I think kevent has arrived to a level of documentation, which makes it 
> possible to get the bigger picture before digging into the code.

Although kevent has documentation, it does not help it, as we can see :)

> I know documentation is boring, especially for people who actually put their 
> ideas into code (some people like to rant about their ideas forever, without 
> actually showing any results). So don't get me wrong; I like your work, but 
> if you want more people to get excited about it, I think you need to 
> communicate it better.

I will write some documentation about overall design and interfaces (it
is a bit easier than kevent, since there is only one syscall with
everyone-likes-it multiplexor inside, and one connector based interface
for netfilter (NAT)).

> Anyway, keep up the good work!

Thank you.

> Hans Henrik 

-- 
	Evgeniy Polyakov
