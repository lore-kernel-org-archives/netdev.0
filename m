From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 10 Dec 2010 20:06:03 +0200
Message-ID: <201012102006.03401.opurdila@ixiacom.com>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com> <201012101932.59352.opurdila@ixiacom.com> <1292002959.3580.321.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:26439 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756779Ab0LJSGF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 13:06:05 -0500
In-Reply-To: <1292002959.3580.321.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Friday 10 December 2010, 19:42:39

> Le vendredi 10 d=E9cembre 2010 =E0 19:32 +0200, Octavian Purdila a =E9=
crit :
> > Would allowing escaping it fix the issue? Like:
> >=20
> > ip link add link bond0 "vlan\*" txqueuelen 100 type vlan id 999
>=20
> Well, same compat problem ;)
>=20
> $ ip link add link bond0 "vlan\*199" type vlan id 199
> $ ifconfig "vlan\*199"

:) Then use a special dev keyword like dev* ?

$ ip link set dev* dummy set

Or use a new flag to allow expansion?

$ ip -e link set dev dummy* set


Thanks,
tavi
