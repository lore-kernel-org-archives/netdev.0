From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 21/22] netoops: Add user-programmable boot_id
Date: Tue, 14 Dec 2010 13:59:44 -0800
Message-ID: <AANLkTi=Q+LaS7yaU_4ThkhMUM-q8S3JTuwMWqAikQPgH@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214213048.17022.58746.stgit@mike.mtv.corp.google.com> <1292362957.3446.851.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.kagstrom-vI6UBbBVNY+JA8cjQkG2/g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1292362957.3446.851.camel@calx>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 1:42 PM, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:
> On Tue, 2010-12-14 at 13:30 -0800, Mike Waychison wrote:
>> Add support for letting userland define a 32bit boot id. =A0This is =
useful
>> for users to be able to correlate netoops reports to specific boot
>> instances offline.
>
> This sounds a lot like the pre-existing /proc/sys/kernel/random/boot_=
id
> that's used by kerneloops.org.

Could be.  I'm looking at it now... There is no documentation for this
boot_id field?

Reusing this guy would work, except that it doesn't appear to allow
arbitrary values to be set.  We need to inject our boot sequence
number (which is figured out in userland) in the packet somehow as we
need to correlate it to our other monitoring systems.

I agree that having the uuid included in the netoops messages would be
very useful.

netoops is probably the wrong place to have a system-wide boot
sequence ID set in retrospect.  For our purposes, I can have it
encoded into the 'user_blob' portion of the packet if folks don't
think the kernel should have any notion of boot sequence number
programmable by userland.
