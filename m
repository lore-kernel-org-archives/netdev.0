From: Valdis.Kletnieks@vt.edu
Subject: Re: network regression: cannot rename netdev twice
Date: Wed, 08 Feb 2012 01:42:04 -0500
Message-ID: <14373.1328683324@turing-police.cc.vt.edu>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com> <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com> <20120204021457.GA25386@khazad-dum.debian.net> <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com> <20120208020038.GE13296@khazad-dum.debian.net>
            <CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1328683324_3347P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 08 Feb 2012 04:50:15 +0100."
             <CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1328683324_3347P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, 08 Feb 2012 04:50:15 +0100, Kay Sievers said:

> After years of working in that area I will stop to work on these hacks
> to promise stable ethX names. It was just wrong, like enumerations
> always are in hotplug setups.

So (real world case) I've got a server that's got a 1G ethernet connected=
 to
the public net, a 1G ethernet that's a cluster management network, and
a 10G ethernet that connects to our HPC clusters.

And I want to add iptables rules that distinguish based on interface. Cur=
rently
I can nail the management net to eth0, the public net to eth1, and the 10=
G to
eth2, and then just add =22-i eth1=22 or whatever in the iptables ruleset=
.

I really don't care if the 0/1/2 move around - but if we're not having na=
iled-down
interface names, what will take the place of '-i ethN' in iptables?

> People who need predictable interface names should just manually
> configure custom/descriptive names, or names which are reliably
> derived from the hardware, like firmware-provided names or the pci
> slot number.

Or is this sort of thing in /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=3D=3D=22net=22, ACTION=3D=3D=22add=22, DRIVERS=3D=3D=22?*=22, A=
TTR=7Baddress=7D=3D=3D=2200:25:90:0b:f2:80=22, ATTR=7Btype=7D=3D=3D=221=
=22, KERNEL=3D=3D=22eth*=22, NAME=3D=22eth0=22
what you are trying to move to, and my systems are already onboard and
I should just move along, nothing to see here? ;)

--==_Exmh_1328683324_3347P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBTzIZOwdmEQWDXROgAQKFqhAAoqjjoFtAHfddKC06dWIBUikCHPFK90ny
cvg8HEMxVcIZBJBUGpXxm8jA9u1Q2GouJ1aYhp4tIQMsN7GjLqKLCPKI+Re1ePDW
4nGSMcGWKY4iE6pWtbmhQfsrcPJtvxgUQCgwAfU5+sTEpBcaoFglA3wvN4WCGrbM
+UzMqwW/E6vuKDn4QY8q6Nc7WqgiDbDaW1ZxRKP2zkY2/Y23u2eY6AfAwj2XV+1c
ft9EmB8fkTwdAYuGY8pWpyN+WKm6H2sAYHggqqxi8PL2Jfw87hNZkJsLFByxldSY
pyDK86pOjG1z88Tq3ZXXxx5RkXx/+ZA3QLpSjKg4TDXkoK9gW8RGWs0WYKHa4biv
VfJFzSem83f31xds+xjKKYkTr4jEyRT/ybfZ2frCagSrr8HDXgR3WhgwqW2N82HV
ECCCE7HGLYzsxb92KsIyVKqosY+OYCQelYmheRnU5sRQvnFfJiTrWExBUs12iSgX
eo0W8RbaQBG+8uJU8N3p2ZFD62/BOyLaoly16/7MJcyghmvEv4QP/yH8Nz3ORHpV
IKJvhSKfiSDBld3ca3+/jE3fhWrVjueLxWcTYHvOmNHvV+Xww8sO/rl0W7x0dnvb
cgAGJZxwd/y5BQOx9V1SGReRYm3zpx8wvgL9OuRXUcmMsxU2AM3akwznfCmeMqRU
RIPoEEwC6Jw=
=JUGY
-----END PGP SIGNATURE-----

--==_Exmh_1328683324_3347P--
