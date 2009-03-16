From: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Tue, 17 Mar 2009 07:55:49 +0800
Message-ID: <b6a2187b0903161655q15437156qc926c8db37d8ba4b@mail.gmail.com>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 <1237140665.24621.2.camel@johannes.local>
	 <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
	 <1237143683.24621.7.camel@johannes.local>
	 <20090315202603.GA9077@elte.hu>
	 <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
	 <alpine.LFD.2.00.0903161250080.3082@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.00.0903161250080.3082-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 17, 2009 at 3:57 AM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> IOW, if you've pinpointed 71c11fb57b924c160297ccd9e1761db598d00ac2 as
> being bad, then you should go back and double-check that its parent
> (in this case 4607816f608b42a5379aca97ceed08378804c99f) is good.
> Because if it's parent is also bad, then that just means that you made
> some mistake in "git bisect".
> In this case, it really sounds like maybe you marked the parent good, even
> though you should have marked it bad.

I should have been more careful, just got thrown off during the last
few steps of the bisect. But with the bad association to the AP after
a57a59f247b651e8ed6d3eeb7e2f9d83b83134c9 (iwlwifi: remove implicit
direct scan), can someone suggest where to go from here?

Meanwhile, I'll try bisecting again.

Thanks,
Jeff.
