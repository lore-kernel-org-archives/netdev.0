From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bonding and ifenslave version.
Date: Wed, 3 Aug 2011 14:33:38 -0700
Message-ID: <20110803143338.03988aab@nehalam.ftrdhcpuser.net>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
	<4E38EE23.8030703@gmail.com>
	<CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>
	<4E39A3A7.1080905@gmail.com>
	<1718.1312402077@death>
	<4E39B1AB.7050502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55998 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077Ab1HCVdg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 17:33:36 -0400
In-Reply-To: <4E39B1AB.7050502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 03 Aug 2011 22:38:03 +0200
Nicolas de Peslo=FCan  <nicolas.2p.debian@gmail.com> wrote:

> Le 03/08/2011 22:07, Jay Vosburgh a =E9crit :
> > Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
> >> Le 03/08/2011 21:03, Andy Gospodarek a =E9crit :
>=20
> >>> Distributions benefit from version numbers on userspace utils.  I=
t
> >>> would probably be better to keep ifenslave's version number as it=
 is
> >>> to help those maintaining those distro packages.
> >>
> >> As one of the maintainers for the ifenslave package on Debian, I p=
erfectly
> >> understand the need for an upstream version, but as such, I expect=
ed the
> >> upstream version number to change when the file change... Version =
numbers
> >> in Debian use upstream version numbers when available and add a su=
bversion
> >> number for Debian specific changes. I would expect to change the v=
ersion
> >> number and not only the Debian subversion when the only change is =
a new
> >> upstream version.
> >
> > 	One thing to remember here is that currently very few (perhaps
> > no) distros use the ifenslave.c that comes with mainline.  The dist=
ros
> > I'm familiar with configure bonding via sysfs, either directly in
> > initscripts / sysconfig, or via a shell script ifenslave (which I
> > believe is what Debian has).  Many distros still install it in
> > /sbin/ifenslave, but it isn't used by the network configuration stu=
ff.
>=20
> The ifenslave package on Debian provide two things:
>=20
> - The binary ifenslave, simply compiled from mainline ifenslave.c.
> - A plug-in for ifupdown to allow for bonding related options in /etc=
/network/interfaces. I can=20
> confirm that this plug-in doesn't use the ifenslave command, but sysf=
s, since version 1.1.0-12=20
> (current stable version of this package is 1.1.0-17).
>=20
> > 	The ifenslave.c in mainline is pretty much just a legacy for
> > backwards compatibility; it has not had a bug fix since 2005 (a few=
 typo
> > repairs since then), and no major functional changes since before t=
he
> > git era.
> >
> > 	I was considering proposing feature removal for ifenslave.c and
> > the ioctl API to add and remove slaves, but some discussion a few m=
onths
> > ago indicated that there are apparently still some users out there =
(I'd
> > guess embedded of some variety).
>=20
> Unfortunately, there exist *many* how-to that suggest to use ifenslav=
e, causing many users to use it=20
> instead of sysfs for bonding setup.
>=20
> At least, we can:
> - update the bonding documentation to clarify that ifenslave is depre=
cated (and move most ifenslave=20
> related stuffs at the end of the documentation);
> - possibly issue a warning when the API is used, suggesting to use sy=
sfs instead.
>=20
> I can take care of the documentation update if appropriate.
>=20
> 	Nicolas.

Or I could just put a shell script that does the same thing in iproute.

