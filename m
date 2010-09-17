From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable-2.6.32] Phonet: disable network namespace support
Date: Fri, 17 Sep 2010 16:03:47 -0700 (PDT)
Message-ID: <20100917.160347.233870631.davem@davemloft.net>
References: <1284763006-22075-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml@vger.kernel.org, netdev@vger.kernel.org,
	remi.denis-courmont@nokia.com, ebiederm@xmission.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752761Ab0IQXD2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 19:03:28 -0400
In-Reply-To: <1284763006-22075-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Sat, 18 Sep 2010 01:36:46 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Network namespace in the Phonet socket stack causes an OOPS when a
> namespace is destroyed. This occurs as the loopback exit_net handler =
is
> called after the Phonet exit_net handler, and re-enters the Phonet
> stack. I cannot think of any nice way to fix this in kernel <=3D 2.6.=
32.
>=20
> For lack of a better solution, disable namespace support completely.
> If you need that, upgrade to a newer kernel.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: David S. Miller <davem@davemloft.net>
