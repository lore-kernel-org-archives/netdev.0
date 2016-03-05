From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch] rose_route_frame() NULL pointer dereference kernel panic
Date: Sat, 5 Mar 2016 20:57:15 +0100
Message-ID: <20160305195715.GA16052@electric-eye.fr.zoreil.com>
References: <56D5FD7A.5080104@free.fr>
 <20160303.170253.1102862150292919836.davem@davemloft.net>
 <56DAFC1A.5000408@free.fr>
 <20160305.112226.2192524821017178121.davem@davemloft.net>
 <56DB1814.2050902@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: f6bvp <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:48095 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbcCET5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 14:57:21 -0500
Content-Disposition: inline
In-Reply-To: <56DB1814.2050902@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

f6bvp <f6bvp@free.fr> :
> Le 05/03/2016 17:22, David Miller a =C3=A9crit :
[...]
> > If that's what he intended he would have implemented the entirety o=
f
> > rose_xmit() as "kfree_skb(skb)".  But that's obviously not the case=
=2E
> >=20
> > The author meant the packet to be sent in some way, perhaps using a
> > default path or something like that.
>=20
> Via a NULL pointer ?
> I don't see how it could work.

Ask G4KLX what he meant when he wrote rose_rebuild_header (since that's
where Eric B. took rose_xmit from) back in the 2.1.9 era ?

See https://git.kernel.org/cgit/linux/kernel/git/history/history.git/co=
mmit/?id=3Dd75df542864496c92ff705d7d072a58b0119a4ff

--=20
Ueimor
