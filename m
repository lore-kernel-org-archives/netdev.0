From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: netdev branch - kernel panic - bug in tcp_time_to_recover ?
Date: Thu, 8 Sep 2005 19:39:28 +0200
Message-ID: <20050908173927.GA4963@oepkgtn.mshome.net>
Reply-To: Mateusz Berezecki <mateuszb@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964897AbVIHRdw@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hello List,

Today I builded recent git snapshot of netdev tree and after a while i
get this (hand noted due to hard lockup - no oops in syslog)

Oops: 0000 [#1]
Modules linked in:=20
CPU: 0
EIP: 0060:[<c03d3162>] Not tainted VLI
EFLAGS: 00010246  (2.6.13-netdev)
EIP is at tcp_time_to_recover+0x62/0xbf

eax: 00920635 ebx: ffffffff ecx: cd1afb90 edx: 00000000
esi: 00000000 edi: cd1afb90 ebp: c05c60b0 esp: c05c6d9c
es =3D ds: 007b  ss : 0068

process: cc1
stack: ... (i can put details here later in next post if you want - im
in hurry now)

call trace:
           show_stack=20
	   show_registers
	   die
	   do_page_fault
	   error_code
	   tcp_fastretrans_alert+0x132
	   tcp_ack
	   tcp_rcv_established
	   tcp_v4_do_rcv
	   tcp_v4_recv
	   ip_local_deliver
	   ...


	  =20
as I stated above, I can repost with more details later in the evening
as I'm in hurry now.


kind regards,
Mateusz

--=20
  @..@   Mateusz Berezecki=20
 (----)  mateuszb@gmail.com http://mateusz.agrest.org
( >__< ) PGP: 5F1C 86DF 89DB BFE9 899E 8CBE EB60 B7A7 43F9 5808=20
^^ ~~ ^^

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDIHdPKu1H8AtEdBoRAsVHAKCJY2ySAdjkYyh9SIDyMqVZxQvYPACbBiwl
1rtztl2gIEoDzeduz0E1nXo=
=SlO8
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--
