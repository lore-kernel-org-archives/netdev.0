From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: various fixes for bonding, netpoll & netconsole
 (v3)
Date: Mon, 18 Oct 2010 11:57:48 -0400
Message-ID: <20101018155748.GB16326@hmsreliant.think-freely.org>
References: <1287021713-1750-1-git-send-email-nhorman@tuxdriver.com>
 <20101018.082529.115920035.davem@davemloft.net>
 <20101018.082728.48512103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, andy@greyhouse.net, amwang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34571 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222Ab0JRP6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 11:58:00 -0400
Content-Disposition: inline
In-Reply-To: <20101018.082728.48512103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 18, 2010 at 08:27:28AM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 18 Oct 2010 08:25:29 -0700 (PDT)
>=20
> > From: nhorman@tuxdriver.com
> > Date: Wed, 13 Oct 2010 22:01:48 -0400
> >=20
> >> Version 3, taking the following changes into account:
> >  ...
> >> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
> > Applied, thanks Neil.
>=20
> This doesn't build with netpoll disable:
>=20
> drivers/net/bonding/bond_main.c: In function =E2=80=98bond_start_xmit=
=E2=80=99:
> drivers/net/bonding/bond_main.c:4578: error: expected expression befo=
re =E2=80=98)=E2=80=99 token
>=20
> I'll fix this up but please properly build test your
> changes next time.


I apologize Dave, I thought I had tested with CONFIG_NET_POLL_CONTROLLE=
R turned
off, but apparently it just got re-enabled automatically because I had
CONFIG_NETPOLL on.  I'll check that more carefully in the future.
Neil


P.S. I've got some minor cleanup patches to this series (little things =
that I
missed) in the next day or so.

Thanks!

Neil
