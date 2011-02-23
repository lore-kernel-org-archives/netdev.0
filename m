From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: long word align struct qdisc_skb_cb data
Date: Wed, 23 Feb 2011 14:17:23 -0800 (PST)
Message-ID: <20110223.141723.39169376.davem@davemloft.net>
References: <4D6534C3.1080305@trash.net>
	<1298480707.3301.386.camel@edumazet-laptop>
	<20110223093001.28e1a8ef@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kaber@trash.net,
	Juliusz.Chroboczek@pps.jussieu.fr, linville@tuxdriver.com,
	netdev@vger.kernel.org, andi@firstfloor.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36770
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753545Ab1BWWQq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 17:16:46 -0500
In-Reply-To: <20110223093001.28e1a8ef@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Feb 2011 09:30:01 -0800

> On Wed, 23 Feb 2011 18:05:07 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le mercredi 23 f=E9vrier 2011 =E0 17:24 +0100, Patrick McHardy a =E9=
crit :
>> > Am 23.02.2011 16:14, schrieb Eric Dumazet:
>> > > diff --git a/include/net/sch_generic.h b/include/net/sch_generic=
=2Eh
>> > > index 16626a0..f40d32e 100644
>> > > --- a/include/net/sch_generic.h
>> > > +++ b/include/net/sch_generic.h
>> > > @@ -218,6 +218,7 @@ struct tcf_proto {
>> > > =20
>> > >  struct qdisc_skb_cb {
>> > >  	unsigned int		pkt_len;
>> > > +	unsigned int		sfb_classid;
>> > >  	char			data[];
>> > >  };
>> >=20
>> > This could be moved into a SFB specific cb, similar to what netem
>> > does.
>>=20
>> Hmm... well... I want to be sure no other sch will destroy my values=
=2E
>>=20
>> netem seems buggy then.
>>=20
>> Probably following patch is needed ?
>=20
> Yes, it was long word aligned when netem was written but
> we seem to have bit creep.

Applied to net-2.6, thanks!
