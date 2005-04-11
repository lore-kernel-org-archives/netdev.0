From: TommyDrum <mycooc@yahoo.it>
Subject: Re: r8169 native module problems on 2.6.11 [SOLVED]
Date: Mon, 11 Apr 2005 02:26:49 +0200
Message-ID: <4259C449.7000306@yahoo.it>
References: <42591914.2000800@yahoo.it> <20050410132601.GA9027@electric-eye.fr.zoreil.com> <425951F6.301@yahoo.it> <20050410170251.GA9537@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050410170251.GA9537@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

O/H Francois Romieu =CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:

| Ok, new pci id, no wonder it does not work. Can you give the attached
patch
| a quick but carefull test on your vanilla kernel ?

Wasn't too quick, sorry, had to supper (very long, I admit it!). It's
modprobed very quick (much faster than the USR provided module) and
works pretty good up 'til now; dmesg is clean, lspci also, and cat
/proc/interrupts doesn't show any conflicts. ifconfig also seems to be
in line, and the interface is up and running smoothly.
IMO all is quiet on this front ;)

I forwarded last message to netdev, also do it with this one.

Keep up the good work Francois, and thanks really a lot!

A presto!
Tommy

P.S. Any other info needed, I'll be glad to provide.


| -----------------------------------------------------------------------=
-
|
| --- a/drivers/net/r8169.c	2005-04-10 18:45:05.200274476 +0200
| +++ b/drivers/net/r8169.c	2005-04-10 18:52:41.197933777 +0200
| @@ -176,6 +176,7 @@ const static struct {
|  static struct pci_device_id rtl8169_pci_tbl[] =3D {
|  	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
|  	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
| +	{0x16ec, 0x0116, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
|  	{0,},
|  };
|

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCWcRCgpUvhTIUBAERArnEAJ9A8/LbF2Mra0pVJS9Lcp+hg0pZ4wCeKAsu
N4L1zAsNmRg15EQOuqcPmEE=3D
=3DS2E/
-----END PGP SIGNATURE-----
