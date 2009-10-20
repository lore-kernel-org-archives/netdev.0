From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 05:48:10 +0200
Message-ID: <4ADD32FA.6030409@gmail.com>
References: <4ADD309B.1040505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58963 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbZJTDsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 23:48:08 -0400
In-Reply-To: <4ADD309B.1040505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :
> I'm having strange issues when running pktgen on 10G interfaces while
> also running
> pktgen on mac-vlans on that interface, when the mac-vlan pktgen threa=
ds
> are on a different
> CPU.
>=20
> First, lockdep gives up and says that things are not properly
> annotated.  I believe this is because
> the macvlan tx path will lock it's txq and will also lock the
> lower-dev's txq.  To fix this, perhaps
> we need some new lockdep aware primitives for netdev txq locking?
>=20
> Second, is using _bh() locking really sufficient if we have pktgen
> writing to a physical device
> and also have other pktgen threads writing to that same device though
> mac-vlans?   I'm seeing
> deadlocks spinning on the _bh() lock in pktgen as well as strange
> corruptions, so I think there
> must be *some* problem somewhere, I just don't know quite what it is =
yet.
>=20

Could you please give us a copy if your pktgen scripts ?
