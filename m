From: Tom Marshall <tommy@home.tig-grr.com>
Subject: 2.6.9-rc1: panic in ipv6_rcv
Date: Tue, 31 Aug 2004 10:40:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831174059.GA22049@home.tig-grr.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[Please reply to me directly, I am not subscribed]

I booted 2.6.9-rc1 (gcc version 3.4.1 (Debian 3.4.1-4sarge1)) and got this
panic within a couple minutes.  The machine is a bridge with two eepro100
cards and no active ebtables or iptables rules.

If this is worth checking into, I can provide more info and/or run any tests
that are appropriate.

  CPU:    0                                                                =
                 =20
  EIP:    0060:[<c98f734e>]  Not tainted VLI                               =
                 =20
  EFLAGS: 00010202   (2.6.9-rc1)
  EIP is at ip6_route_input+0x1ae/0x2e0 [ipv6]
  eax: 00000000   ebx: 00000004   ecx: c9921d38   edx: c9921c60
  esi: c9921c60   edi: 00000000   ebp: 00000000   esp: c031deac
  ds: 007b   es: 007b   ss: 0060
  Process swapper (pid: 0, threadinfo=3Dc031c000 task=3Dc02aca40)
  Stack: c9921d38 c7fdbc38 c7fdbc20 00000000 c7b80000 80000000 00000003 c60=
c1140
         c60c1140 c7b80000 c0357fa8 c98ef810 c60c1140 c60c1140 00000000 000=
00000
         c0357ua8 c7b8007b 0000007b c0357f98 c60c1140 c9921fc0 c022e7dd c60=
c1140
  Call Trace:
   [<c98ef810>] ipv6_rcv+0x250/0x270 [ipv6]
   [<c022e7dd>] netif_receive_skb+0x1ed/0x220
   [<c022e88f>] process_backlog+0x7f/0x100
   [<c022e97a>] net_rx_action+0x6a/0xf0
   [<c011ad91>] __do_softirq+0x41/0x90
   [<c011ae07>] do_softirq+0x27/0x30
   [<c01068ed>] do_IRQ+0x10d/0x130
   [<c01049c8>] common_interrupt+0x18/0x20
   [<c027007b>] igmpv3_del_delrec+0xab/0xc0
   [<c0101f33>] default_idle+0x23/0x40
   [<c0101fbd>] cpu_idle+0x2d/0x40
   [<c031e7a3>] start_kernel=3D0x163/0x180
   [<c031e380>] unknown_bootoption+0x0/0x170=20
  Code: 8d b6 00 00 00 00 8d bc 27 00 00 00 00 8b 12 85 d2 74 27 8b 42 10 3=
9 58 34
   0f 84 fe 00 00 00 f6 40 54 08 74 e8 8b 82 88 00 00 00 <8b> 00 39 58 34 7=
5 c2 89
   d7 8b 12 85 d2 75 d9 85 ff 89 fb 75 0f
   <0>Kernel panic - not syncing: Fatal exception in interrupt

--=20
You know the great thing about TV?  If something important happens
anywhere at all in the world, no matter what time of the day or night,
you can always change the channel.
        -- Jim Ignatowski

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEARECAAYFAkE0uCsACgkQFMm9uvwPXW5mSACgko+gug5ETRB9G74JevRuu9M1
wqkAoI1tHYN+WuWKJ3umV4NcskilbYXj
=0FAi
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--
