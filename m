From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sun, 15 Mar 2009 11:41:58 +0100
Message-ID: <200903151141.59098.rjw@sisk.pl>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera> <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com> <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b6a2187b0903142006u546fad9eme66f9ea7b464b81f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 15 March 2009, Jeff Chua wrote:
> On Sun, Mar 15, 2009 at 10:58 AM, Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Sun, Mar 15, 2009 at 3:01 AM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
> >> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=12414
> >> Subject         : iwl4965 cannot use "ap auto" on latest 2.6.28/29?
> >> Submitter       : Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Date            : 2009-01-05 4:13 (69 days old)
> >> References      : http://marc.info/?l=linux-kernel&m=123112882127823&w=4
> >
> > Still not working in linux-2.6.29-rc8. Broken after the commit below.
> > There were many changes to wireless after this commit, and simply
> > reverting this commit will break compiling.
> >
> > Jeff.
> >
> >
> >
> > commit 41bb73eeac5ff5fb217257ba33b654747b3abf11
> > Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > Date:   Wed Oct 29 01:09:37 2008 +0100
> >
> >    mac80211: remove SSID driver code
> >
> 
> The commit below is causing problem with associating with the hidden AP as well.
> 
> Thanks,
> Jeff.
> 
> 
> 71c11fb57b924c160297ccd9e1761db598d00ac2 is first bad commit
> commit 71c11fb57b924c160297ccd9e1761db598d00ac2
> Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date:   Tue Oct 28 18:29:48 2008 +0100
> 
>     b43/legacy: remove SSID code
> 
>     The SSID programmed into the device is used by the ucode only
>     to reply to probe requests, a functionality we disable anyway
>     because it doesn't fit with the mac80211/hostapd programming
>     model. Therefore, it isn't useful to program the SSID into
>     device.
> 
>     Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
>     Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Thanks for the update.

Rafael
