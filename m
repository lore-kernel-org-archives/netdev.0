From: Ben Greear <greearb@candelatech.com>
Subject: Re: Fw: [Bugme-new] [Bug 4441] New: unregister_netdevice Prompt and
 system shell lookup when trying to shutdown vlan
Date: Mon, 04 Apr 2005 08:44:17 -0700
Message-ID: <425160D1.6060701@candelatech.com>
References: <20050404041822.2ea0c16a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, dcmwai@pl.jaring.my
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050404041822.2ea0c16a.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
>=20
> Begin forwarded message:
>=20
> Date: Mon, 4 Apr 2005 04:15:25 -0700
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 4441] New: unregister_netdevice Prompt and sy=
stem shell lookup when trying to shutdown vlan
>=20
>=20
> http://bugme.osdl.org/show_bug.cgi?id=3D4441
>=20
>            Summary: unregister_netdevice Prompt and system shell lookup=
 when
>                     trying to shutdown vlan
>     Kernel Version: 2.6.11-gentoo-r4 i686
>             Status: NEW
>           Severity: high
>              Owner: acme@conectiva.com.br
>          Submitter: dcmwai@pl.jaring.my
>=20
>=20
> Distribution:=20
> Gentoo, FC2, FC3=20
>=20
> Hardware Environment:
> Pentium 4 3.0E,
> Intel SE7210TP1-E Server Entry Board
> 512 MB DDR Ram
> 2x Intel=AE PRO/1000 Dual Port Adapters
>=20
> Software Environment:
> Portage 2.0.51.19 (default-linux/x86/2005.0, gcc-3.3.5, glibc-2.3.4.200=
41102-r1)
> Fc2 and Fc2 original kernel.
>=20
> Problem Description:
> When Shutdown a Vlan using this command
> vconfig rem eth4.1001
> The interface will be down (using ifconfig)
> However the following error will be prompt on the screen and the log le=
aving the
> shell to be not responding.
>=20
> Even if "ifconfig eth4.1001 down" is run before "vconfig rem" sill the =
problem
> will be there.
> The only way I tested on solve this problem is to shutdown the interfac=
e totally.
> ifconfig eth4 down
>=20
> Then the vlan can be removed correctly.
>=20
> This problem don't happen on the following "special Condition"
> 1) On another motherboard (Gigabyte GA-81PE1000-G) same NIC on Fc3
> 1) On eth0=20
>=20
>=20
> Steps to reproduce:
> 1. get a vlan supported NIC, emerge vconfig
> 2. ifconfig ethx 0.0.0.0
> 3. create a vlan using "vconfig add ethx nnnn"
> 4. ifconfig ethx.nnnn aaa.bbb.ccc.ddd
> 5. remove the vlan using "vconfig rem ethx.nnnn"
> 6. Wait for the error like the below.
> * Motherboard and NIC seem to be a Problem in my case.
>=20
> unregister_netdevice: waiting for ethx.nnnn to become free. Usage count=
 =3D 6

In the past, IPv6 has often been the problem here.  Are you using IPv6?

What is the hardware/driver for eth4?

Thanks,
Ben

>=20
> I've also open a bug in Gentoo
> http://bugs.gentoo.org/show_bug.cgi?id=3D87495
>=20
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
>=20


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
