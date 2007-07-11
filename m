From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 12:50:12 -0400
Message-ID: <46950A44.2040808@hp.com>
References: <OF12E7973A.D9D0F9C5-ON88257315.005882D0-88257315.0058D5B9@us.ibm.com> <200707111919.11746@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	=?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F?=
	 =?ISO-8859-1?Q?=3F?= <yoshfuji@linux-ipv6.org>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:47739 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459AbXGKQwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 12:52:08 -0400
In-Reply-To: <200707111919.11746@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi Denis-Courmont wrote:
> Le mercredi 11 juillet 2007, David Stevens a =E9crit :
>>         That sounds like a good idea to me (FWIW),
>> though I also still think a simple raw-socket
>> application would do it just fine, possibly with
>> no kernel modification at all.
>>         But since the kernel wouldn't be maintaining
>> the DNS info, which was my real objection to the
>> original version,  netlink would work well too.
>=20
> One remaining corner case is NFS/IPv6 root, whereby userland won't ha=
ve=20
> a chance to start before the network, and hence may miss the solicite=
d=20
> RA. Or would it? By default, the next unsolicited RA can be anytime=20
> from now to after 10 minutes, so that's not sufficient. I wouldn't=20
> personnaly care, but...
>=20

You've got the same issue with the socket option approach.

-vlad
