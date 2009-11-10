From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10] netdev: get rid of read_lock(&dev_base_lock) usages
Date: Tue, 10 Nov 2009 19:39:20 +0100
Message-ID: <4AF9B358.9030006@gmail.com>
References: <20091110175446.280423729@vyatta.com>	<4AF9AE66.3010303@gmail.com> <20091110102442.733c22bc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50608 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757583AbZKJSjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:39:17 -0500
In-Reply-To: <20091110102442.733c22bc@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> I was just trying to pick up the stragglers you left behind :-)
>=20
> The nasty cases left are bonding (whose existing locking model is a p=
ile
> of crap), and sysfs (slightly less stinky). The bonding code just nee=
ds to
> be rewritten to have a sane/simple model.=20
>=20

I was thinking of improving bonding, so it might be good to coordinate =
our work :)

1) Get rid of rwlock in tx fast path. (RCU ? did I said RCU)

2) multi queue support (Got two dual 82599 dual ports cards from Intel =
:) )

