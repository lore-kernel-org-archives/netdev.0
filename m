From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Computer fails to resume from suspend unless I rmmod jme before
 initiating the suspend
Date: Mon, 22 Feb 2016 11:09:07 +0100
Message-ID: <20160222100907.GA32071@amd>
References: <CA+ToGPGC8APhN-_F5fzyR4CWqWgZ9Hs0PNqykhEgEV7g3PJjTg@mail.gmail.com>
 <CA+ToGPF9cpdVLEHc7Vz79=-P7Jp76Y=M=p=bORhUNrXtb6+LNA@mail.gmail.com>
 <CA+ToGPHfV5NbSAFWJPzDVfUT9fdp86MqoFbF8Uhmf9T+3e9n7Q@mail.gmail.com>
 <CA+ToGPF0OT7NKCjaBMomqZg-+eO7Eq9hqSmLt0-UOHnyGPHd8Q@mail.gmail.com>
 <CA+ToGPFP5a76TS2C_A7WJUWM9Eo60Ym5OtwHcKtY+OreoRVoFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Diego Viola <diego.viola@gmail.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:56309 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbcBVKJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 05:09:19 -0500
Content-Disposition: inline
In-Reply-To: <CA+ToGPFP5a76TS2C_A7WJUWM9Eo60Ym5OtwHcKtY+OreoRVoFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> >>>> Every time I initiate a suspend (systemctl suspend) the machine hangs
> >>>> at resume unless I unload the jme driver.

It seems to have some kind of suspend/resume support. ... and it is
rather complex.

Maybe jme_start_irq(jme) should be moved to the end of jme_resume
function?

> > So I found that disabling async as in:
> >
> > $ echo 0 > /sys/power/pm_async
> >
> > Helps with my issue, I can't reproduce the hang anymore, tried
> > suspend/resume almost ~15 times.
> >
> > Diego
> 
> Can someone please help?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
