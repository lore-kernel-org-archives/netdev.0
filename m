From: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Fri, 20 Mar 2009 18:04:29 +0800
Message-ID: <b6a2187b0903200304l469e3eeet87c51b1cddb43ea8@mail.gmail.com>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <1237143683.24621.7.camel@johannes.local>
	 <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <1237317742.31814.28.camel@johannes.local>
	 <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com>
	 <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com>
	 <1237455534.5100.56.camel@johannes.local>
	 <b6a2187b0903192155q33510b57l9d5927538a0f4f99@mail.gmail.com>
	 <1237537967.5100.135.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1237537967.5100.135.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 20, 2009 at 4:32 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> 1) It can't be before iwconfig which will result in "SET failed on
> device wlan0 ; Device or resource busy".
>  So your point 1) confuses me. Can you
> explain that a little more?

This is what happened ...

# modprobe -r iwlagn
# modprobe iwlagn
# ifconfig wlan0 up
# iwconfig wlan0 mode Managed
Error for wireless request "Set Mode" (8B06) :
    SET failed on device wlan0 ; Device or resource busy.


> As for 2), that is very very strange since ap auto channel auto is the
> default, so saying that before you do anything else should do anything
> at all.
>
> I suspect something is going on in the driver because the ifconfig order
> matters and for mac80211, it shouldn't make a difference when the state
> machine is really started. I'll probably need to try to reproduce this,
> but to be honest between the varying failure modes, undefined wireless
> extensions semantics, etc. I'm not very confident I can.

I'll try all the different combination again for 2.6.28, and see if
it's the same, and on the other AP that seems harder to associate (but
works well in 2.6.28, and other OSs include Nokia phones ... so I
don't think it's the AP problem ... because it's been around a while
and gone thru many 2.6.xx).

It worked so well before that I didn't even bother to think twice, and
I may have made silly mistakes along the way, so pardon me if I
confused you.

Thanks for your help.

Jeff.
