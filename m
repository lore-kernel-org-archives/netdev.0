From: Willy Gardiol <willy@gardiol.org>
Subject: Re: The 8169 driver: issue with cross cable
Date: Wed, 23 Feb 2005 19:05:00 +0100
Message-ID: <200502231905.02656.willy@gardiol.org>
References: <200502192011.25428.willy@gardiol.org> <200502201712.49589.willy@gardiol.org> <20050223003056.GA12696@electric-eye.fr.zoreil.com>
Reply-To: willy@gardiol.org
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1207170.ZnF2qGF01C";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050223003056.GA12696@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1207170.ZnF2qGF01C
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


On the client fstab is:
/dev/sda1               /boot           ext2            noatime,noauto     =
     =20
0 0
192.168.0.1:/shimitar   /               nfs            =20
noatime,rsize=3D8192,wsize=3D8192           0 0
192.168.0.1:/shimitar/home      /home           nfs            =20
noatime,rsize=3D8192,wsize=3D8192           0 0
192.168.0.1:/shimitar/deposito  /deposito               nfs            =20
noatime,rsize=3D16384,wsize=3D16384 0 0
192.168.0.1:/shimitar/deposito2 /deposito2              nfs            =20
noatime,rsize=3D16384,wsize=3D16384 0 0

(sda1 is a USB key, not mounted by default)

On the server fstab is:
/dev/hdc1               /shimitar       ext3            noatime            =
    =20
0 0
/dev/hdc2               /shimitar/home  ext3            noatime            =
    =20
0 0
/dev/hda4               /shimitar/deposito2     ext3            noatime    =
            =20
0 0
/dev/hdc4               /shimitar/deposito      ext3            noatime    =
            =20
0 0

And exports is:
/shimitar 192.168.0.2(rw,no_root_squash,async,no_subtree_check)
/shimitar/home 192.168.0.2(rw,no_root_squash,async,no_subtree_check)
/shimitar/deposito 192.168.0.2(rw,no_root_squash,async,no_subtree_check)
/shimitar/deposito2 192.168.0.2(rw,no_root_squash,async,no_subtree_check)
/mnt/tmp                192.168.0.2(rw,no_root_squash,async,no_subtree_chec=
k)

(mnt/tmp is not mounted on the client).

Something i did not emphatized: both boxes are connected to the internet vi=
a=20
another eth device.=20
The network configuration is:
=2D a switch 100mbit connected to the internet, each box has a direct cable=
 to=20
the switch (via 8139too eth device on both boxes). Dhcp.
=2D a cross cable between the two boxes connecting the r8169 eth device.=20
192.168.0.0/24.


Alle Wednesday 23 February 2005 01:30, Francois Romieu ha scritto:
> Willy Gardiol <willy@gardiol.org> :
> [...]
>
> > http://www.gardiol.org/r8169/1000-client.tar.bz2
> > http://www.gardiol.org/r8169/1000-server.tar.bz2
> > http://www.gardiol.org/r8169/100-client.tar.bz2
> > http://www.gardiol.org/r8169/100-server.tar.bz2
>
> Can you add a minimal exports/mount option description so that
> I try to reproduce it here ?
>
> --
> Ueimor

=2D-=20

!=20
 Willy Gardiol - willy@gardiol.org
 www.gardiol.org
 +39 3492800983
 Use linux for MY freedom.=20
 Your freedom may come as a side effect.

   "L'altrove =E8 uno specchio in negativo.=20
    Il viaggiatore riconosce il poco che =E8 suo,=20
    scoprendo il molto che non ha avuto e non avr=E0"

      Italo Calvino - Le citt=E0 invisibili


--nextPart1207170.ZnF2qGF01C
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCHMXOvgbSPju7wvkRAr6XAJ9YNArolHldzPvdhuTcjRyrpNHIDwCgvWU1
jpPgb1pfXaJ0Ui0D0z0RfLM=
=n5M+
-----END PGP SIGNATURE-----

--nextPart1207170.ZnF2qGF01C--
