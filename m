From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bonding and ifenslave version.
Date: Thu, 4 Aug 2011 09:57:04 -0700
Message-ID: <20110804095704.46c453d0@nehalam.ftrdhcpuser.net>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
	<4E38EE23.8030703@gmail.com>
	<CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>
	<4E39A3A7.1080905@gmail.com>
	<1718.1312402077@death>
	<4E39B1AB.7050502@gmail.com>
	<20110803143338.03988aab@nehalam.ftrdhcpuser.net>
	<4E3A2EBA.4040003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55962 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755286Ab1HDQ4y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 12:56:54 -0400
In-Reply-To: <4E3A2EBA.4040003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Aug 2011 07:31:38 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 03/08/2011 23:33, Stephen Hemminger a =E9crit :
> > On Wed, 03 Aug 2011 22:38:03 +0200
> > Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
> <snip>
> >> At least, we can:
> >> - update the bonding documentation to clarify that ifenslave is de=
precated (and move most ifenslave
> >> related stuffs at the end of the documentation);
> >> - possibly issue a warning when the API is used, suggesting to use=
 sysfs instead.
> >>
> >> I can take care of the documentation update if appropriate.
> >>
> >> 	Nicolas.
> >
> > Or I could just put a shell script that does the same thing in ipro=
ute.
>=20
> You mean, to replace ifenslave (from ifenslave.c) by a shell script b=
y the same name that gives=20
> users the same command-line interface but use sysfs instead of the io=
ctl API internally?
>=20
> I had this in mind two years ago, in a private conversation while cha=
nging the ifenslave package on=20
> Debian.
>=20
> But chance exist that those who expect ifenslave to work would like t=
o disable sysfs support if not=20
> used. I assume that totally disabling sysfs at compile time would red=
uce the size of the kernel far=20
> more that disabling the ioctl API. So, for those doing embedded thing=
s, this may makes sens to have=20
> an ifenslave version that doesn't rely on sysfs.
>=20
> Or do you mean, to replace ifenslave (.c) by a shell script that use =
netlink internally? Are all the=20
> bonding options available through netlink? I remember many conversati=
on about using netlink for=20
> bonding setup, but don't remember seeing that in the actual code.

The sysfs interface is the least desirable.
The ifenslave script would just call 'ip link'

