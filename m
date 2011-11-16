From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/9] Cleanup and extension of netdev features
Date: Wed, 16 Nov 2011 17:49:36 -0500 (EST)
Message-ID: <20111116.174936.1998571821116555319.davem@davemloft.net>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898Ab1KPWul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:50:41 -0500
In-Reply-To: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Wed, 16 Nov 2011 02:29:54 +0100 (CET)

> Commit fd38f734 (igbvf: convert to ndo_fix_features) removed last use
> of old ethtool ops for controlling netdevice's features. This series
> finishes the cleanup and extends feature pool to 64 bits.
>=20
> Also, there's additional patch that removes NETIF_F_NO_CSUM as it is
> now, and has been for some time, equivalent to NETIF_F_HW_CSUM.
>=20
> To see the new features in action, you need ethtool patched with:
>=20
> http://patchwork.ozlabs.org/patch/96374/
>=20
> Not much has changed in those patches compared to the version I poste=
d
> in June. v4->v5 is a rebase to current net-next.
>=20
> Only compile tested. Kernels newer than 3.1-rcSomething don't boot fo=
r
> me because of some block layer or dm-crypt issue I don't have time to
> debug now. :-(

All applied, thanks a lot for doing this work.
