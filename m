From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Computer fails to resume from suspend unless I rmmod jme before
 initiating the suspend
Date: Mon, 22 Feb 2016 20:20:15 +0100
Message-ID: <20160222192015.GA4011@amd>
References: <CA+ToGPGC8APhN-_F5fzyR4CWqWgZ9Hs0PNqykhEgEV7g3PJjTg@mail.gmail.com>
 <CA+ToGPF9cpdVLEHc7Vz79=-P7Jp76Y=M=p=bORhUNrXtb6+LNA@mail.gmail.com>
 <CA+ToGPHfV5NbSAFWJPzDVfUT9fdp86MqoFbF8Uhmf9T+3e9n7Q@mail.gmail.com>
 <CA+ToGPF0OT7NKCjaBMomqZg-+eO7Eq9hqSmLt0-UOHnyGPHd8Q@mail.gmail.com>
 <CA+ToGPFP5a76TS2C_A7WJUWM9Eo60Ym5OtwHcKtY+OreoRVoFA@mail.gmail.com>
 <20160222100907.GA32071@amd>
 <CA+ToGPE3=OBsNDP_O7EoT76FqMdxdjdt=+tHNGBbm-oUkQHA4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, cooldavid@cooldavid.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Diego Viola <diego.viola@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+ToGPE3=OBsNDP_O7EoT76FqMdxdjdt=+tHNGBbm-oUkQHA4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2016-02-22 15:59:48, Diego Viola wrote:
> On Mon, Feb 22, 2016 at 7:09 AM, Pavel Machek <pavel@ucw.cz> wrote:
> > Hi!
> >
> >> >>>> Every time I initiate a suspend (systemctl suspend) the machine hangs
> >> >>>> at resume unless I unload the jme driver.
> >
> > It seems to have some kind of suspend/resume support. ... and it is
> > rather complex.
> >
> > Maybe jme_start_irq(jme) should be moved to the end of jme_resume
> > function?
> >
> >> > So I found that disabling async as in:
> >> >
> >> > $ echo 0 > /sys/power/pm_async
> >> >
> >> > Helps with my issue, I can't reproduce the hang anymore, tried
> >> > suspend/resume almost ~15 times.
> >> >
> >> > Diego
> >>
> >> Can someone please help?
> 
> Hi Pavel,
> 
> This did the trick, suspend/resume is now working perfectly for me
> (tried more than 10 times). :)
> 
> Thank you so much, should I send a patch?

Yes please.

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
