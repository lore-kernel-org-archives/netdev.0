From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/10] netdev: get rid of read_lock(&dev_base_lock)
 usages
Date: Tue, 10 Nov 2009 10:53:36 -0800
Message-ID: <20091110105336.4fde9c81@nehalam>
References: <20091110175446.280423729@vyatta.com>
	<4AF9AE66.3010303@gmail.com>
	<20091110102442.733c22bc@nehalam>
	<4AF9B358.9030006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54157 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244AbZKJSyC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:54:02 -0500
In-Reply-To: <4AF9B358.9030006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 19:39:20 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > I was just trying to pick up the stragglers you left behind :-)
> >=20
> > The nasty cases left are bonding (whose existing locking model is a=
 pile
> > of crap), and sysfs (slightly less stinky). The bonding code just n=
eeds to
> > be rewritten to have a sane/simple model.=20
> >=20
>=20
> I was thinking of improving bonding, so it might be good to coordinat=
e our work :)

I'll be happy to review, but was avoiding doing any serious work on it.

>=20
> 1) Get rid of rwlock in tx fast path. (RCU ? did I said RCU)
>=20
> 2) multi queue support (Got two dual 82599 dual ports cards from Inte=
l :) )

I hope to get back to doing netlink interface for bridging, then bondin=
g
over next few weeks.

--=20
