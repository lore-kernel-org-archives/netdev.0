From: "Bernard, f6bvp" <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Thu, 02 Oct 2008 20:20:18 +0200
Message-ID: <1222971618.6267.26.camel@f6bvp-5>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local>
	 <48E1F417.7080304@free.fr> <20080930101030.GA6290@ff.dom.local>
	 <20080930111733.GB6290@ff.dom.local> <48E29337.2080400@free.fr>
	 <20080930213052.GA6449@ami.dom.local> <48E2ACDE.30406@free.fr>
	 <20081001055828.GA10831@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:47350 "EHLO smtp2-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753448AbYJBSTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 14:19:09 -0400
In-Reply-To: <20081001055828.GA10831@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

=46inally I am able to access the faulty 2.6.27-rc7 f6bvp-9 system via
ssh.
I can read /var/log/kernel/message file immediately after a kernel
failure and a reboot.=20
When this is done, the system is stable until I start FPAC suite
applications (fpad, fpacwpd ...) as shown below.

Oct  2 16:50:00 f6bvp-9 kernel: AX25_DBG: c36fc338, 00000000, 1, 0, 0
Oct  2 16:50:00 f6bvp-9 kernel: AX25_DBG: c36fc008, 00000000, 1, 1, 0
Oct  2 16:50:00 f6bvp-9 kernel: AX25_DBG: c36fc338, 00000000, 1, 0, 0
Oct  2 16:50:00 f6bvp-9 kernel: AX25_DBG: c36fc008, 00000000, 1, 1, 0
Oct  2 16:50:09 f6bvp-9 fpad: starting FPAD
Oct  2 16:50:09 f6bvp-9 kernel: AX25_DBG: c691a688, 00000000, 2, 2, 17
Oct  2 16:50:09 f6bvp-9 kernel: AX25_DBG: c15245f0, 00000000, 11, 5, 0
Oct  2 16:50:09 f6bvp-9 kernel: AX25_DBG: c691a688, 00000000, 2, 2, 17
Oct  2 16:50:09 f6bvp-9 kernel: AX25_DBG: c691a688, 00000000, 2, 2, 17
Oct  2 16:50:09 f6bvp-9 fpad: FPAD becomes a daemon=20
Oct  2 16:50:09 f6bvp-9 fpacwpd[5169]: Starting
Oct  2 16:50:09 f6bvp-9 kernel: AX25_DBG: c691a688, 00000000, 2, 2, 17
Oct  2 16:50:10 f6bvp-9 last message repeated 6 times
Oct  2 16:50:10 f6bvp-9 ax25ipd: assemble_kiss: dumped - control byte
non-zero=20
Oct  2 16:50:10 f6bvp-9 kernel: mkiss: ax4: Trying crc-smack
Oct  2 16:50:10 f6bvp-9 kernel: AX25_DBG: c691a688, 00000000, 2, 2, 17
Oct  2 16:50:10 f6bvp-9 last message repeated 7 times
Oct  2 16:50:10 f6bvp-9 fpad: FPAD opened WP service=20
Oct  2 16:50:11 f6bvp-9 ax25ipd: assemble_kiss: dumped - control byte
non-zero=20
Oct  2 16:50:11 f6bvp-9 kernel: mkiss: ax4: Trying crc-flexnet
Oct  2 16:50:11 f6bvp-9 kernel: mkiss: ax0: Trying crc-smack
Oct  2 16:50:13 f6bvp-9 kernel: AX25_DBG: c1520630, 00000000, 11, 5, 0
Oct  2 16:50:16 f6bvp-9 ax25ipd: from_kiss: dumped - cannot figure out
where to send this!=20
Oct  2 16:50:16 f6bvp-9 kernel: mkiss: ax0: Trying crc-flexnet
Oct  2 16:50:18 f6bvp-9 ax25ipd: from_kiss: dumped - cannot figure out
where to send this!=20
Oct  2 16:50:21 f6bvp-9 kernel: AX25_DBG: c36090e0, 00000000, 3, 2, 207
Oct  2 16:50:21 f6bvp-9 kernel: mkiss: ax1: Trying crc-smack
Oct  2 16:50:22 f6bvp-9 ax25ipd: from_kiss: dumped - cannot figure out
where to send this!=20
Oct  2 16:50:25 f6bvp-9 kernel: AX25_DBG: c14662d0, 00000000, 11, 5, 0
Oct  2 16:50:26 f6bvp-9 kernel: mkiss: ax1: Trying crc-flexnet
Oct  2 16:50:28 f6bvp-9 kernel: AX25_DBG: c4cd0a68, 00000000, 11, 5, 0
Oct  2 16:50:28 f6bvp-9 ax25ipd: from_kiss: dumped - cannot figure out
where to send this!=20
Oct  2 16:50:30 f6bvp-9 kernel: AX25_DBG: c691a688, 00000000, 2, 2, 17
Oct  2 16:50:30 f6bvp-9 last message repeated 2 times
Oct  2 16:50:31 f6bvp-9 ax25ipd: from_kiss: dumped - cannot figure out
where to send this!=20
Oct  2 16:50:31 f6bvp-9 kernel: AX25_DBG: c146a5d0, 00000000, 11, 5, 0
Oct  2 16:50:31 f6bvp-9 kernel: AX25_DBG: c36090e0, 00000000, 3, 2, 207
Oct  2 16:50:31 f6bvp-9 kernel: mkiss: ax3: Trying crc-smack
Oct  2 16:50:33 f6bvp-9 ax25ipd: from_kiss: dumped - cannot figure out
where to send this!=20
Oct  2 16:53:21 f6bvp-9 syslogd 1.4.2: restart.
Oct  2 16:53:22 f6bvp-9 kernel: klogd 1.4.2, log source =3D /proc/kmsg
started.
Oct  2 16:53:23 f6bvp-9 kernel: Linux version 2.6.27-rc7 (root@f6bvp-9)
(gcc version 4.2.2 20071128 (prerelease) (4.2.2-3.1mdv2008.0)) #3 Tue
Sep 30 10:55:01 CEST 2008
Oct  2 16:53:23 f6bvp-9 kernel: BIOS-provided physical RAM map:
Oct  2 16:53:23 f6bvp-9 kernel:  BIOS-e820: 0000000000000000 -
00000000000a0000 (usable)
Oct  2 16:53:23 f6bvp-9 kernel:  BIOS-e820: 00000000000f0000 -
0000000000100000 (reserved)
Oct  2 16:53:23 f6bvp-9 kernel:  BIOS-e820: 0000000000100000 -
0000000008000000 (usable)
Oct  2 16:53:23 f6bvp-9 kernel:  BIOS-e820: 00000000ffff0000 -
0000000100000000 (reserved)
Oct  2 16:53:23 f6bvp-9 kernel: last_pfn =3D 0x8000 max_arch_pfn =3D
0x100000
Oct  2 16:53:23 f6bvp-9 kernel: RAMDISK: 07f2a000 - 07fef581
=20
Although I did not change anything, and contrarily to my previous
observation, the system instability as shown above occurs
systematically.
There was no problem with Kernel 2.6.25-10 I was using before (with
patches for AX25 and ROSE that are now included in 2.6.27-rc7).
I did not try 2.6.26 on this machine, thus I cannot tell if the bug was
already present.
Would it be worth to test 2.6.26 ?  =20
With the SSH limited access I have from my remote site, can I continue
this debuging effort constructively, or do we wait until I am back in
front of the local console ?

Bernard =20

Le mercredi 01 octobre 2008 =C3=A0 05:58 +0000, Jarek Poplawski a =C3=A9=
crit :
> On Wed, Oct 01, 2008 at 12:49:02AM +0200, Bernard Pidoux F6BVP wrote:
> > Jarek,
> >
> > With the patch #2, there have been only one reboot after the machin=
e was =20
> > frozen. I did not notice that was happening for there was no kernel=
 =20
> > panic message but a frozen display only.
> > Then I could only write down partially the values displayed after =20
> > AX25_DBG: c446c220, c..... 3, 5, 240
> > Second number was not 000000 as it is most of the time.
> > The machine rebooted after the usual 60 seconds delay and since the=
n =20
> > there was no kernel panic.
> > This is the first time kernel 2.6.27-rc7 does not panic within a mi=
nute.
> > The system is up since about 20 minutes now with frequent AX25_DBG =
messages.
>=20
> Hmm... Since this was intended mainly for debugging something went
> wrong. (I expected to get at least one warning.)
>=20
> >
> > I am sorry that I must go to sleep now to be at work early in the m=
orning.
> > I will be away from my Linux box for a few days.
> > Then we should probably interrupt this interesting bug hunting.
> > I will send more results when I am back.
>=20
> OK, I'll try to look at this in the meantime.
>=20
> Cheers,
> Jarek P.
>=20

