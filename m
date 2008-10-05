From: "Bernard, f6bvp" <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sun, 05 Oct 2008 23:18:20 +0200
Message-ID: <1223241500.18094.32.camel@f6bvp-5>
References: <20081002194845.GB2664@ami.dom.local>
	 <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local>
	 <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local>
	 <20081004200939.GB15152@ami.dom.local> <1223231469.18094.10.camel@f6bvp-5>
	 <20081005204013.GB2526@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:36628 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754657AbYJEVRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2008 17:17:12 -0400
In-Reply-To: <20081005204013.GB2526@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek,

Yes, previous reports were without reverting David's patch.
Now I have removed David's patch (ax25_std_timer.c) and reverted 9A4GL
patch (af_ax25.c).
Thus present kernel is the original plus 9A4GL patch plus your AX25_DBG
and netrom patches and minus David's patch.
The system has been stable for two hours and there is nothing special
in /var/log/messages as can be seen the sample below.  =20

Oct  5 22:56:15 f6bvp-9 kernel: AX25_DBG: c6530350, 00000000, 2, 2, 17
Oct  5 22:56:15 f6bvp-9 last message repeated 7 times
Oct  5 22:56:15 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 16, 3, 0
Oct  5 22:56:15 f6bvp-9 kernel: AX25_DBG: c6530350, 00000000, 2, 2, 17
Oct  5 22:56:15 f6bvp-9 last message repeated 7 times
Oct  5 22:56:26 f6bvp-9 kernel: AX25_DBG: c3846a08, 00000000, 11, 5, 0
Oct  5 22:57:07 f6bvp-9 kernel: AX25_DBG: c6530350, 00000000, 2, 2, 17
Oct  5 22:57:07 f6bvp-9 kernel: AX25_DBG: c3936cb8, 00000000, 2, 2, 17
Oct  5 22:57:26 f6bvp-9 kernel: AX25_DBG: c3846a08, 00000000, 11, 5, 0
Oct  5 22:58:14 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 3, 2, 207
Oct  5 22:58:44 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 3, 2, 207
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931998, 00000000, 1, 0, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931cc8, 00000000, 1, 1, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931998, 00000000, 1, 0, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931cc8, 00000000, 1, 1, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931998, 00000000, 1, 0, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931cc8, 00000000, 1, 1, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931998, 00000000, 1, 0, 0
Oct  5 22:58:56 f6bvp-9 kernel: AX25_DBG: c3931cc8, 00000000, 1, 1, 0
Oct  5 22:58:58 f6bvp-9 kernel: AX25_DBG: c3931998, 00000000, 1, 0, 0
Oct  5 22:58:58 f6bvp-9 kernel: AX25_DBG: c3931cc8, 00000000, 1, 1, 0
Oct  5 22:58:58 f6bvp-9 kernel: AX25_DBG: c3931998, 00000000, 1, 0, 0
Oct  5 22:58:58 f6bvp-9 kernel: AX25_DBG: c3931cc8, 00000000, 1, 1, 0
Oct  5 22:59:14 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 3, 2, 207
Oct  5 22:59:26 f6bvp-9 kernel: AX25_DBG: c3846a08, 00000000, 11, 5, 0
Oct  5 22:59:44 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 3, 2, 207
Oct  5 22:59:44 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 6, 5, 0
Oct  5 23:00:04 f6bvp-9 kernel: AX25_DBG: c38e1248, 00000000, 2, 1, 6
Oct  5 23:00:12 f6bvp-9 kernel: AX25_DBG: c6530350, 00000000, 2, 2, 17
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0c58, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0668, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0c58, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0668, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0668, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 mountd[3369]: authenticated mount request from
f6bvp-11:980 for /temp (/temp)
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0c58, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0078, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0c58, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0668, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0c58, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 mountd[3369]: authenticated unmount request fro=
m
f6bvp-11:983 for /temp (/temp)
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0668, 00000000, 2, 1, 6
Oct  5 23:00:23 f6bvp-9 kernel: AX25_DBG: c38e0078, 00000000, 2, 1, 6
Oct  5 23:01:01 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 16, 3, 9
Oct  5 23:01:01 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:01 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:01 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:01 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:01 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 16, 3, 9
Oct  5 23:01:02 f6bvp-9 crond[4112]: (root) CMD (nice -n 19 run-parts
--report /etc/cron.hourly)
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 16, 3, 9
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 2, 0
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c38e1248, 00000000, 2, 1, 6
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c66e2ce8, 00000000, 10, 1, 6
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c6530350, 00000000, 2, 2, 17
Oct  5 23:01:02 f6bvp-9 last message repeated 2 times
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c38e1248, 00000000, 2, 1, 6
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c66e2ce8, 00000000, 10, 1, 6
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:02 f6bvp-9 kernel: AX25_DBG: c6530350, 00000000, 2, 2, 17
Oct  5 23:01:03 f6bvp-9 last message repeated 2 times
Oct  5 23:01:03 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:03 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:03 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:03 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:04 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:04 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:04 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:04 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805998, 00000000, 1, 0, 0
Oct  5 23:01:05 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 1, 0
Oct  5 23:01:06 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 16, 3, 9
Oct  5 23:01:06 f6bvp-9 kernel: AX25_DBG: c38d1a30, 00000000, 16, 3, 9
Oct  5 23:01:06 f6bvp-9 kernel: AX25_DBG: c3805cc8, 00000000, 1, 2, 0

Bernard


Le dimanche 05 octobre 2008 =C3=A0 22:40 +0200, Jarek Poplawski a =C3=A9=
crit :
> On Sun, Oct 05, 2008 at 08:31:09PM +0200, Bernard, f6bvp wrote:
> > Here are a few interesting data captured via netconsole from
> > kernel-2.6.27-rc7 without af_netrom patch #4.
> >=20
> ...
> > AX25_DBG: c67ef160, c5189aa8, 6, 5, 0
> ...
> > AX25_DBG: c67eed48, c5186008, 6, 5, 0
>=20
> So, it looks like this patch could make some change, but I'd like to =
be
> sure again: with or without David's patch?
>=20
> Thanks,
> Jarek P.
>=20

