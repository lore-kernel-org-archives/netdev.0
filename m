From: Bill Fink <billfink@mindspring.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 03:18:16 -0500
Message-ID: <20120215031816.7afeef08.billfink@mindspring.com>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	<5133914.uYLb0gnNTc@localhost.localdomain>
	<1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<5781419.24ZaHfTAxC@localhost.localdomain>
	<1329280993.2555.21.camel@edumazet-laptop>
	<CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
	<1329286016.2555.41.camel@edumazet-laptop>
	<20120215025200.6e6f02a2.billfink@mindspring.com>
	<1329292820.2555.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>, alekcejk@googlemail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:39031 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757925Ab2BOISV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 03:18:21 -0500
In-Reply-To: <1329292820.2555.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Feb 2012, Eric Dumazet wrote:

> Le mercredi 15 f=E9vrier 2012 =E0 02:52 -0500, Bill Fink a =E9crit :
>=20
> > Would it be useful to check if there was any difference in
> > TCP parameters between the 3.1 and 3.2 kernels by performing
> > the following on each:
> >=20
> > 	grep . /sys/module/tcp_*/parameters/*
> >=20
> > 					-Bill
>=20
> I did yesterday and found nothing interesting.

Do your SYSCTL1 and SYSCTL2 files include /sys/module/tcp_*
as well as /proc/sys?  Not that I know of anything that might
have changed in /sys/module/tcp_* between 3.1 and 3.2, but
you never know what a particular distro might have tweaked.

					-Bill



> # diff SYSCTL1 SYSCTL2
> 13a14
> > kernel.sched_cfs_bandwidth_slice_us =3D 5000
> 18c19
> < kernel.tainted =3D 513
> ---
> > kernel.tainted =3D 4609
> 33c34
> < kernel.threads-max =3D 48402
> ---
> > kernel.threads-max =3D 48398
> 35c36
> < kernel.random.entropy_avail =3D 2200
> ---
> > kernel.random.entropy_avail =3D 1715
> 38,39c39,40
> < kernel.random.boot_id =3D da6427fc-eb8e-40a8-8809-8cae94a65fb5
> < kernel.random.uuid =3D 118c4362-a2a2-4973-ab3e-a09a0ed306ff
> ---
> > kernel.random.boot_id =3D 2f77031a-9e65-4358-9c02-09058831507a
> > kernel.random.uuid =3D 44cdd730-9c00-4a85-87c3-0a5b1c7c1278
> 52a54
> > kernel.cap_last_cap =3D 35
> 102,103c104,105
> < kernel.osrelease =3D 2.6.41.10-3.fc15.i686
> < kernel.version =3D #1 SMP Mon Jan 23 15:44:18 UTC 2012
> ---
> > kernel.osrelease =3D 2.6.42.3-2.fc15.i686
> > kernel.version =3D #1 SMP Thu Feb 9 01:39:19 UTC 2012
> 111c113
> < kernel.msgmni =3D 1675
> ---
> > kernel.msgmni =3D 1674
> 116c118
> < kernel.pty.nr =3D 2
> ---
> > kernel.pty.nr =3D 3
> 152,155c154,157
> < fs.inode-nr =3D 9875	61
> < fs.inode-state =3D 9875	61	0	0	0	0	0
> < fs.file-nr =3D 7328	0	309733
> < fs.file-max =3D 309733
> ---
> > fs.inode-nr =3D 23853	1607
> > fs.inode-state =3D 23853	1607	0	0	0	0	0
> > fs.file-nr =3D 6112	0	309720
> > fs.file-max =3D 309720
> 157c159
> < fs.dentry-state =3D 9913	1327	45	0	0	0
> ---
> > fs.dentry-state =3D 27730	17922	45	0	0	0
> 168c170
> < fs.epoll.max_user_watches =3D 337762
> ---
> > fs.epoll.max_user_watches =3D 337644
> 272c274
> < net.netfilter.nf_conntrack_count =3D 62
> ---
> > net.netfilter.nf_conntrack_count =3D 26
> 284,285c286,287
> < net.core.wmem_default =3D 114688
> < net.core.rmem_default =3D 114688
> ---
> > net.core.wmem_default =3D 163840
> > net.core.rmem_default =3D 163840
> 301d302
> < net.ipv4.route.gc_interval =3D 60
> 601c602
> < net.ipv6.conf.all.regen_max_retry =3D 5
> ---
> > net.ipv6.conf.all.regen_max_retry =3D 3
> 630c631
> < net.ipv6.conf.default.regen_max_retry =3D 5
> ---
> > net.ipv6.conf.default.regen_max_retry =3D 3
> 659c660
> < net.ipv6.conf.lo.regen_max_retry =3D 5
> ---
> > net.ipv6.conf.lo.regen_max_retry =3D 3
> 688c689
> < net.ipv6.conf.eth0.regen_max_retry =3D 5
> ---
> > net.ipv6.conf.eth0.regen_max_retry =3D 3
