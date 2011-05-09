From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next-2.6] veth: use batched device unregister
Date: Mon, 09 May 2011 11:22:55 +0200
Message-ID: <1304932975.3342.19.camel@edumazet-laptop>
References: <1304793749.3207.26.camel@edumazet-laptop>
	 <1304838742.3207.45.camel@edumazet-laptop>
	 <F57561A93EFF5E88729A8D53@nimrod.local>
	 <7B76F9D75FD26D716624004B@nimrod.local>
	 <20110508125028.GK2641@linux.vnet.ibm.com>
	 <B2891EFD056565BBD4DBCE16@nimrod.local>
	 <20110508134425.GL2641@linux.vnet.ibm.com>
	 <C449131127D58077CB25C9D8@Ximines.local>
	 <20110508144749.GR2641@linux.vnet.ibm.com>
	 <AB9DE9E04289CF29CA79CC67@Ximines.local>
	 <20110508154854.GT2641@linux.vnet.ibm.com>
	 <1304888447.3207.66.camel@edumazet-laptop>
	 <1304916275.3207.79.camel@edumazet-laptop>
	 <1304927148.3342.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46895 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab1EIJW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 05:22:58 -0400
Received: by wya21 with SMTP id 21so3715065wya.19
        for <netdev@vger.kernel.org>; Mon, 09 May 2011 02:22:57 -0700 (PDT)
In-Reply-To: <1304927148.3342.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 09:45 +0200, Eric Dumazet a =C3=A9crit :
> veth devices dont use the batched device unregisters yet.
>=20
> Since veth are a pair of devices, it makes sense to use a batch of tw=
o
> unregisters, this roughly divide dismantle time by two.
>=20
> Reported-by: Alex Bligh <alex@alex.org.uk>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Ben Greear <greearb@candelatech.com>
> ---
> v2: added a list_del(&list) for safety (see commit ceaaec98)

Just to make things clear, please dont apply this patch, since I posted
another version including Micha=C5=82 idea.

thanks


