From: Sedat Dilek <sedat.dilek-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Sun, 27 Feb 2011 16:23:59 +0100
Message-ID: <AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
References: <20110225222210.GA3618@tuxdriver.com>
Reply-To: sedat.dilek-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110225222210.GA3618-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 25, 2011 at 11:22 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> Announcement
>
> The bufferbloat project [1] is pleased to announce the availability
> of the debloat-testing Linux kernel git tree:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0git://git.infradead.org/debloat-testing.gi=
t
>
> The purpose of this tree is to provide a reasonably stable base for
> the development and testing of new algorithms, miscellaneous fixes,
> and maybe a few hacks intended to advance the cause of eliminating
> or at least mitigating bufferbloat in the Linux world.
>
> Introduction
>
> Bufferbloat is a term coined by Jim Gettys to describe the increasing
> prevalence of large and (particularly) unmanaged network buffers alon=
g
> the network links that comprise the Internet [2]. =C2=A0If you are no=
t aware
> of the problems with network latency under load that the Internet is
> already encountering, we encourage you to visit Jim Gettys' blog [3].
> There Jim has begun to fit together enough puzzle pieces to at least
> frame the issue.
>
> Jim has also made available slides and an audio recording (edited
> for time) from a presentation on this topic:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0http://mirrors.bufferbloat.net/Talks/BellL=
abs01192011/
>
> Kernel Bits
>
> The debloat-testing tree is intended to track full and -rc releases
> from linux-2.6, with interesting patches cherry-picked from net-next
> and various experimental bits added on top. =C2=A0The current stable =
of
> such patches includes the following:
>
> Eric Dumazet (based on original work by Juliusz Chroboczek):
> =C2=A0 =C2=A0 =C2=A0net_sched: SFB flow scheduler
>
> stephen hemminger:
> =C2=A0 =C2=A0 =C2=A0sched: CHOKe flow scheduler
>
> John Fastabend:
> =C2=A0 =C2=A0 =C2=A0net: implement mechanism for HW based QOS
> =C2=A0 =C2=A0 =C2=A0net_sched: implement a root container qdisc sch_m=
qprio
>
> John W. Linville:
> =C2=A0 =C2=A0 =C2=A0mac80211: implement eBDP algorithm to fight buffe=
rbloat
>
> Nathaniel J. Smith:
> =C2=A0 =C2=A0 =C2=A0iwlwifi: Simplify tx queue management
> =C2=A0 =C2=A0 =C2=A0iwlwifi: Convert the tx queue high_mark to an ato=
mic_t
> =C2=A0 =C2=A0 =C2=A0iwlwifi: Invert the sense of the queue high_mark
> =C2=A0 =C2=A0 =C2=A0iwlwifi: auto-tune tx queue size to minimize late=
ncy
> =C2=A0 =C2=A0 =C2=A0iwlwifi: make current tx queue sizes visible in d=
ebugfs
>
> Dave Taht:
> =C2=A0 =C2=A0 =C2=A0Bufferbloat reduction for the e1000 driver that s=
tarted it all
> =C2=A0 =C2=A0 =C2=A0Reduce bufferbloated default for e1000e, increase=
 dynamic range
> =C2=A0 =C2=A0 =C2=A0Smash bufferbloat in the ath9k driver
>
> Userland Bits
>
> Patches for the userspace tc utility incorporating support for both t=
he
> CHOKe AQM and the Stochastic Fair Blue scheduler (SFB) are available:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0https://github.com/dtaht/iproute2bufferblo=
at
>
> Contributions
>
> Please send any experimental or research-oriented patches related to
> bufferbloat to the bloat-devel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org list. =C2=A0Remi=
nders
> of more mainstream patches that may be relevant and/or interesting
> for cherry-picking into debloat-testing are welcome there as well.
>
> Obviously, patches that are ready for normal merge consideration
> should continue to be sent to netdev, linux-wireless, linux-kernel,
> or whatever other existing list is appropriate for them.
>
> Thanks
>
> Finally, we want to offer a huge thanks to the 130+ new members of
> the bloat mailing list [4] for leaping into the fray, and to David
> Woodhouse for hosting the debloat-testing tree at infradead.
>
> Please help us beat the bloat. =C2=A0Good luck, and happy debloating!
>
> Notes
>
> [1] http://bufferbloat.net
> [2] http://gettys.wordpress.com/what-is-bufferbloat-anyway/
> [3] http://en.wordpress.com/tag/bufferbloat/
> [4] https://lists.bufferbloat.net
> --
> John W. Linville =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0might be all we have. =C2=A0Be ready.
>

Hi,

it should be "localversion-debloat" in the commit-subject in [1] (not
"localversion-wireless") :-).
"-db" as suffix is IMHO not very meaningful... Why not add simply a
suffix called "-debloat"?
(Anyway, I will revert this patch because I don't want to have any
suffix added automatically.)

I have several other questions, but I start compiling first and test
this debloat kernel.

Regards,
- Sedat -

[1] "Add localversion-wireless to identify builds from this tree."
http://git.infradead.org/debloat-testing.git/commit/3f9bdb4f44b076feda7=
2d353d8ad717831416f36
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
