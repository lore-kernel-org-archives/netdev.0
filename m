From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] phonet: use call_rcu for phonet device
 free
Date: Wed, 09 Jun 2010 16:15:07 -0700 (PDT)
Message-ID: <20100609.161507.226788333.davem@davemloft.net>
References: <20100607132738.GB2730@psychotron.lab.eng.brq.redhat.com>
	<474f08fed4a406e929af3d4142d3e185@chewa.net>
	<1275918583.2545.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi@remlab.net, jpirko@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752348Ab0FIXO4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 19:14:56 -0400
In-Reply-To: <1275918583.2545.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 15:49:43 +0200

> Le lundi 07 juin 2010 =E0 15:43 +0200, R=E9mi Denis-Courmont a =E9cri=
t :
>> On Mon, 7 Jun 2010 15:27:39 +0200, Jiri Pirko <jpirko@redhat.com> wr=
ote:
>> > Use call_rcu rather than synchronize_rcu.
>> >=20
>> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>=20
>> This looks fine to me, but what is the goal here? The RCU documentat=
ion
>> seems to imply that synchronize_rcu() is preferable over call_rcu() =
when at
>> all possible.
>>=20
>=20
> Thats not exactly that.
>=20
> synchronize_rcu() is easier, in respect of memory use.
> But its drawback is current thread is blocked for several milli secon=
ds.
>=20
> In the end, call_rcu() is more scalable.
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
