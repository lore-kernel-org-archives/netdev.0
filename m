From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sun, 15 Mar 2009 11:44:31 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>  <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>  <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>  (sfid-20090315_040645_344726_0E746861) <1237140665.24621.2.camel@johannes.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1237140665.24621.2.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Sun, 15 Mar 2009, Johannes Berg wrote:

> On Sun, 2009-03-15 at 11:06 +0800, Jeff Chua wrote:
> 
> > The commit below is causing problem with associating with the hidden AP as well.
> 
> > 71c11fb57b924c160297ccd9e1761db598d00ac2 is first bad commit
> > commit 71c11fb57b924c160297ccd9e1761db598d00ac2
> > Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > Date:   Tue Oct 28 18:29:48 2008 +0100
> > 
> >     b43/legacy: remove SSID code
> > 
> >     The SSID programmed into the device is used by the ucode only
> >     to reply to probe requests, a functionality we disable anyway
> >     because it doesn't fit with the mac80211/hostapd programming
> >     model. Therefore, it isn't useful to program the SSID into
> >     device.
> 
> That's not believable, sorry. I know exactly what the microcode uses the
> SSID here for, and it never uses it when we're in station mode.

Jeff - can you test the kernels before-and-after this commit (with _no_ 
other changes) and descibe the differences?

Johannes - "not believable" is simply not an argument. If Jeff can show a 
difference, then your disbelief is totally irrelevant, and clearly shows 
that you are basing your beliefs on incorrect assumptions (like some 
specific version of firmware that isn't the whole story).

		Linus
