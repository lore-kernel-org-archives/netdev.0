From: Alex Samad <alex@samad.com.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 16:08:10 +1100
Message-ID: <20081016050810.GA8240@samad.com.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081015.215536.242281148.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 15, 2008 at 09:55:36PM -0700, David Miller wrote:
> From: Alex Samad <alex@samad.com.au>
> Date: Thu, 16 Oct 2008 14:04:16 +1100
>=20
> [ Kernel network developers don't read linux-net, which is for
>   user discussion.  They read netdev@vger.kernel.org instead
>   which I've added to the CC:, please maintain this in all
>   follow ups and replys. ]
>=20
> > I seems to be getting lots of crashes when my system is under network
> > load, I was moving 1/4T of data over a 1G link and I got lots and lots
> > of these
>=20
> What kernel version?

Sorry I put this at the bottom of the email.  its a stock debian 2.6.26
(-8) kernel, nothing special on my side

>=20
> How is your system configured?

 lspci -s 0a.0 -vv
00:0a.0 Ethernet controller: nVidia Corporation Device 0760 (rev a2)
	Subsystem: Giga-byte Technology Device e000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dfast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0 (250ns min, 5000ns max)
	Interrupt: pin A routed to IRQ 1277
	Region 0: Memory at f8007000 (32-bit, non-prefetchable)
[size=3D4K]
	Region 1: I/O ports at d800 [size=3D8]
	Region 2: Memory at f8008000 (32-bit, non-prefetchable)
[size=3D256]
	Region 3: Memory at f8009000 (32-bit, non-prefetchable)
[size=3D16]
	Capabilities: <access denied>
	Kernel driver in use: forcedeth
	Kernel modules: forcedeth

I have eth0 bridged to brhme1.

I have seen this problem when doing rsync/ssh of large files and whilst
doing transfer of files with nfs (udp & tcp thought more issues arise
with udp), also tried different mtu's as well and that was worst of all.

The thing to note was (for example), when I was doing a nfs transfer, it
would not be nfs that would crash, it would be other network based
application that would cause the problem, for ex sshd, apache etc


>=20
> Otherwise it is harder for us to analyze this report.
>=20
> Thanks.
>=20

[snip]

> > somebody if it would help.
> >=20
> > Is this a bug or ?
> >=20
> > I am running debian 2.6.26-8=20
> > Linux max 2.6.26-1-amd64 #1 SMP Thu Oct 9 14:16:53 UTC 2008 x86_64
> > GNU/Linux
> >=20
> >=20
> > I have eth0 bridges to brhme1 (so that I can attach virtual box machines
> > there - none attached currently)
> >=20
> > and I have some firewall rules as well.  That really about it to the
> > changes I have made
> >=20
> >=20
> >=20
> > Thanks
> > Alex=20
> >=20
> > PS can you cc me on the replay, in the process of registering
> >=20
> >=20
> > --=20
> > "Columbia carried in its payroll classroom experiments from some of our=
 students in America."
> >=20
> > 	- George W. Bush
> > 02/03/2003
> > Bethesda, MD
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=20
"If there's a leak out of my administration, I want to know who it is. If t=
he person has violated law, that person will be taken care of."

	- George W. Bush
09/30/2003
Washington, DC
Commenting on the CIA leak that he and Cheney later admitted they approved

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkj2zDYACgkQkZz88chpJ2MScgCguQIRw+TlNIsKZP7//Xw+12YI
aH8AoMIeMBTxDURVcN/yP9EswAmrXYox
=rvPy
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--
