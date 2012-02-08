From: Valdis.Kletnieks@vt.edu
Subject: Re: network regression: cannot rename netdev twice
Date: Wed, 08 Feb 2012 15:06:12 -0500
Message-ID: <10120.1328731572@turing-police.cc.vt.edu>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com> <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com> <20120204021457.GA25386@khazad-dum.debian.net> <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com> <20120208020038.GE13296@khazad-dum.debian.net> <CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com> <14373.1328683324@turing-police.cc.vt.edu>
            <CAPXgP10-W+yeHJMENzWi7FBkYOaXw6ccMMMT=K9X2bf_Tigitw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1328731572_2846P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 08 Feb 2012 11:57:18 +0100."
             <CAPXgP10-W+yeHJMENzWi7FBkYOaXw6ccMMMT=K9X2bf_Tigitw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1328731572_2846P
Content-Type: text/plain; charset=us-ascii

On Wed, 08 Feb 2012 11:57:18 +0100, Kay Sievers said:
> On Wed, Feb 8, 2012 at 07:42,  <Valdis.Kletnieks@vt.edu> wrote:

> > Or is this sort of thing in /etc/udev/rules.d/70-persistent-net.rules
> > SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:25:90:0b:f2:80", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"
> > what you are trying to move to, and my systems are already onboard and
> > I should just move along, nothing to see here? ;)
>
> Yeah, that's what we did in the past. It works fine if you never have
> to swap names like eth0 and eth1, with need to free one of the the
> names with a temporary rename.

Well, if I had my druthers, I'd stick name="net-mgt", "net-pub", and "net-10g"
in the udev rules, and not care about 1/2/3 and race conditions, because
meaningful names are easier to not screw up (just last week found a system that
had eth1 and eth2 reversed in some iptables rules, wouldn't have happened if
they were -mgt and -pub).

Only thing stopping me is getting iptables to accept '-i net-10g', and the
distro /etc/sysconfig/network scripts like ifup and ifdown playing nice....

So it sounds like what I want as a sysadmin is the same thing you want
as a maintainer...



--==_Exmh_1328731572_2846P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBTzLVswdmEQWDXROgAQKTow/+PfuLy+BL6CkiXgzQ6L1DnUU/lXkmfiTQ
k2+SkNdngLkflPcnhDf3I9v3aoA14Q7hq5v/vtsaMZf115yo/b1ON+m8yeo2LxYs
CJlu9wTIJq7xzpjDlJgfmzCIl+XZMiui8+J6q7aRus7mnkyFKF1uvaY07nusXzzO
k3K1YWJJnrjmCcwONwogTXRUnes8nXwBVomHV2PSSWAad6IcAxd/3Ai5ryeixYuA
aDGAfGWjcgxzDB93G/ZIG0HdbguLuOdjVt5DBAezXJGqIzd+Ipg1fj8lkdNb3Tfl
j8AmPiiDIzxwNqzrWSy4gabHaXlD0zgQuwp3+HddQW96U6RQvh+LlfhtRLySv+FN
gcO5rWX7IIpqGFtgfXkOm6uET+RqSqNWBVM2aAQEcAn3klkuvxUEt2Y0zFs3tplJ
OMOL4HYNBkq6Gmrbin1H8YaIOiyXeXP8floFxe0Sp8l/XA4FTDwkrStxKKJFEiy5
VUpX77hs8lzpLzmSyx8gzEfY6RGuSpZhmy9Hov8EybHhlh5IcCpE8PSZIyOny3eZ
WaEwbYnbUeT565BwCVtoWL79Eilt9p8pDD+xIKE2E9WP0G5iYO6M4Aqs3R76qtQI
vg0Sji4ITIUCQcMT3SfYGHrRM//ZHRcuXkLT2let4QUHdSs0Krfpxs8BDnDbn8g6
PJvns7OWjwA=
=3HYM
-----END PGP SIGNATURE-----

--==_Exmh_1328731572_2846P--
