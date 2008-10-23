From: David Miller <davem@davemloft.net>
Subject: Re: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i
 cannot navigate
Date: Thu, 23 Oct 2008 14:07:22 -0700 (PDT)
Message-ID: <20081023.140722.193705068.davem@davemloft.net>
References: <20081021184539.GA3320@ami.dom.local>
	<20081021.163207.157978465.davem@davemloft.net>
	<Pine.LNX.4.64.0810221244390.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, sentiniate@tiscali.it, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, olon@verizon.net
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38023
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751541AbYJWVHo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 17:07:44 -0400
In-Reply-To: <Pine.LNX.4.64.0810221244390.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 22 Oct 2008 13:00:01 +0300 (EEST)

> [PATCH] tcp: Restore ordering of TCP options for the sake of inter-op=
erability
>=20
> This is not our bug! Sadly some devices cannot cope with the change
> of TCP option ordering which was a result of the recent rewrite of
> the option code (not that there was some particular reason steming
> from the rewrite for the reordering) though any ordering of TCP
> options is perfectly legal. Thus we restore the original ordering
> to allow interoperability with/through such broken devices and add
> some warning about this trap. Since the reordering just happened
> without any particular reason, this change shouldn't cost us
> anything.
>=20
> There are already couple of known failure reports (within close
> proximity of the last release), so the problem might be more
> wide-spread than a single device. And other reports which may
> be due to the same problem though the symptoms were less obvious.
> Analysis of one of the case revealed (with very high probability)
> that sack capability cannot be negotiated as the first option
> (SYN never got a response).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Reported-by: Aldo Maggi <sentiniate@tiscali.it>
> Tested-by: Aldo Maggi <sentiniate@tiscali.it>

Applied and I'll queue up for -stable, thanks!
