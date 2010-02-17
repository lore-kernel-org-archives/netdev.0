From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 3/3] net: reserve ports for applications using fixed port numbers
Date: Wed, 17 Feb 2010 18:01:07 +0200
Message-ID: <201002171801.07333.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <4B7C159A.3060603@redhat.com> <1266424768.3075.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:20772 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751814Ab0BQRBO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 12:01:14 -0500
In-Reply-To: <1266424768.3075.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 February 2010 18:39:28 you wrote:
> Le jeudi 18 f=E9vrier 2010 =E0 00:13 +0800, Cong Wang a =E9crit :
> > I don't think so, if you want to avoid race condition, you just nee=
d to
> > write the reserved ports before any networking application starts, =
IOW,
> > as early as possible during boot.
>=20
> Sure, but I was thinking retrieving the list of reserved port by a
> database query, using network :)
>=20
> Anyway, I just feel your argument is not applicable.
>=20
> Our kernel is capable of doing an intersection for us, we dont need
> to forbid user to mark a port as 'reserved' if this port is already
> blacklisted by another mechanism (for example, if this port is alread=
y
> in use)
>=20

Also I believe that ip_local_port_range purpose is not to reserve *spec=
ific*=20
ports. Changing this setting helps with things like increasing the port=
 space=20
for NAT or for a higher connection rate.

We add the new option for reserving *specific* ports.=20

So, even from a functional perspective, it makes more sense to me to ke=
ep them=20
independent, as they serve different purposes.
