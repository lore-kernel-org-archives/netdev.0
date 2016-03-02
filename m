From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: Computer fails to resume from suspend unless I rmmod jme before initiating the suspend
Date: Wed, 2 Mar 2016 13:04:28 +0800
Message-ID: <20160302045337.M30306@cooldavid.org>
References: <CA+ToGPGC8APhN-_F5fzyR4CWqWgZ9Hs0PNqykhEgEV7g3PJjTg@mail.gmail.com> <CA+ToGPF9cpdVLEHc7Vz79=-P7Jp76Y=M=p=bORhUNrXtb6+LNA@mail.gmail.com> <CA+ToGPHfV5NbSAFWJPzDVfUT9fdp86MqoFbF8Uhmf9T+3e9n7Q@mail.gmail.com> <CA+ToGPF0OT7NKCjaBMomqZg-+eO7Eq9hqSmLt0-UOHnyGPHd8Q@mail.gmail.com> <CA+ToGPFP5a76TS2C_A7WJUWM9Eo60Ym5OtwHcKtY+OreoRVoFA@mail.gmail.com> <20160222100907.GA32071@amd>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>, Diego Viola <diego.viola@gmail.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:56026 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbcCBFKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 00:10:43 -0500
In-Reply-To: <20160222100907.GA32071@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Diego and who concerns about this driver:

Thanks for reporting it. I can still provide some help, but it's just I'm quite busy.
So that you have not seem me sending patch for a long time.

I wrote this driver when I wan an intern in JMicron during one of my summer vacation
while I'm still student in 2008. And form that point, I do the maintenance just
for fun, not taking any money from them.

JMicron stopped contact me for a long time, and Diego told me that JMicron told him
this chip was EOL 6 years ago.

I have a confidential spec of this chip. I can still provide some help.

Diego is working closely with me for this issue right now.

On Mon, 22 Feb 2016 11:09:07 +0100, Pavel Machek wrote
> Hi!
> 
> > >>>> Every time I initiate a suspend (systemctl suspend) the machine hangs
> > >>>> at resume unless I unload the jme driver.
> 
> It seems to have some kind of suspend/resume support. ... and it is
> rather complex.
> 
> Maybe jme_start_irq(jme) should be moved to the end of jme_resume
> function?
> 
> > > So I found that disabling async as in:
> > >
> > > $ echo 0 > /sys/power/pm_async
> > >
> > > Helps with my issue, I can't reproduce the hang anymore, tried
> > > suspend/resume almost ~15 times.
> > >
> > > Diego
> > 
> > Can someone please help?
> 
> 									Pavel
> -- 
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html


Guo-Fu Tseng
