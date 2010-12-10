From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 10 Dec 2010 19:32:59 +0200
Message-ID: <201012101932.59352.opurdila@ixiacom.com>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com> <20101210081846.58b67f09@nehalam> <1291998740.3580.162.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"Lucian Adrian Grijincu" <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9122 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752977Ab0LJRdC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:33:02 -0500
In-Reply-To: <1291998740.3580.162.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Friday 10 December 2010, 18:32:20

> Le vendredi 10 d=E9cembre 2010 =E0 08:18 -0800, Stephen Hemminger a =E9=
crit :
> > On Fri, 10 Dec 2010 16:58:12 +0200
> >=20
> > Octavian Purdila <opurdila@ixiacom.com> wrote:
> > > Allow the users to specify a wildcard when selecting a device:
> > >=20
> > > $ ip set link dev dummy* up
> > >=20
> > > We do this by expanding the original command line in multiple lin=
es
> > > which we then feed via a pipe to a forked ip processed run in bat=
ch
> > > mode.
> >=20
> > Seems like feature creep. Can't you do this with bash completion
> > script instead.

This feature would make my life easier so to me its just a nice feature=
  :)=20
Sure I can do it as a bash completion script but:

- bash does not run everywhere

- having it in iproute would make it available to everyone

- its userspace so the price to pay for a few more lines of code for us=
ability=20
seems reasonable

- I don't know how scalable you can make the bash completion script

> furthermore, "*" is allowed in a device name
>=20
> ip link add link bond0 "vlan*" txqueuelen 100 type vlan id 999
>=20

Would allowing escaping it fix the issue? Like:

ip link add link bond0 "vlan\*" txqueuelen 100 type vlan id 999

