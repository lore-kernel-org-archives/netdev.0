From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH/RFC] Adding IP(v6) address with scope link creates
 global address
Date: Mon, 07 Dec 2009 20:30:05 +0100
Message-ID: <1260214205.9431.53.camel@amd64.fatal.se>
References: <20091125135945.GA7195@amd64.fatal.se>
	 <20091207134108.GA23087@amd64.fatal.se>  <4B1D38CE.1060001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Jedasothi <sotheme@nphiuu.mine.nu>,
	Bug 487745 <487745@bugs.launchpad.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:63807 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715AbZLGT2q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 14:28:46 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy3.bredband.net (7.3.140.3)
        id 4AD3E1BA0178B8F4 for netdev@vger.kernel.org; Mon, 7 Dec 2009 20:28:45 +0100
In-Reply-To: <4B1D38CE.1060001@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding submitter and launchpad bug to CC.

On m=C3=A5n, 2009-12-07 at 12:18 -0500, Brian Haley wrote:
> Hi Andreas,
>=20
> Andreas Henriksson wrote:
> > Hello again!
> >=20
> > Replying to myself (see http://www.spinics.net/lists/netdev/msg1139=
43.html)
> > and attaching an untested patch to see if this sparks more interest=
=2E
> >=20
> > On Wed, Nov 25, 2009 at 02:59:45PM +0100, Andreas Henriksson wrote:
> >> "Jedasothi" reported problems setting scope with iproute on newly =
added
> >> ipv6 addresses in:
> >> https://bugs.launchpad.net/ubuntu/+source/iproute/+bug/487745
> >>
> >>> To reproduce bug run
> >>> ip addr add '::4/64' scope link dev eth0
> >>>
> >>> This results in a line seen with
> >>> ip addr show eth0
> >>> inet6 ::4/64 scope global tentative
> >>>
> >>> The label "global" is seen instead of "link".
> >=20
> > I'd appreciate if someone could review and test this:
>=20
> I tried the patch quickly since I was curious why this is a problem, =
but
> it didn't work exactly right.  I could post an update, but I'm not su=
re
> this is the right thing to do - ::4 isn't a link-local address, and o=
ther
> parts of the network stack (and other systems) aren't going to treat =
it as
> such.
>=20
> Maybe the submitter can explain exactly how this is breaking somethin=
g?
>=20
> Thanks,
>=20
> -Brian

