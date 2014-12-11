From: David Miller <davem@davemloft.net>
Subject: Re: [net] gre: fix the inner mac header in nbma gre tunnels xmit
 path
Date: Thu, 11 Dec 2014 15:07:06 -0500 (EST)
Message-ID: <20141211.150706.1736198745550279282.davem@davemloft.net>
References: <1418282079-30245-1-git-send-email-timo.teras@iki.fi>
	<20141211.143627.1516156524809595238.davem@davemloft.net>
	<20141211214456.7cc621e4@vostro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com,
	alexander.h.duyck@redhat.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933337AbaLKUHI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:07:08 -0500
In-Reply-To: <20141211214456.7cc621e4@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Teras <timo.teras@iki.fi>
Date: Thu, 11 Dec 2014 21:44:56 +0200

> On Thu, 11 Dec 2014 14:36:27 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
>=20
>> From: Timo Ter=E4s <timo.teras@iki.fi>
>> Date: Thu, 11 Dec 2014 09:14:39 +0200
>>=20
>> > @@ -266,6 +262,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff
>> > *skb,
>> >  		 * to gre header.
>> >  		 */
>> >  		skb_pull(skb, tunnel->hlen + sizeof(struct iphdr));
>> > +		skb_reset_mac_header(mac);
>>=20
>> Please explain to me how this compiles, let alone be functionally
>> tested.
>=20
> Sorry. I made the change twice; once on the build box. And again on m=
y
> git checkout on work station. Must've been on seriously coffee depriv=
ed
> state.
>=20
> Should be obviously:
> +		skb_reset_mac_header(skb);
>=20
> Is there other comments on it?

I don't care where you applied the patch, if you didn't type make after
making the change, that is extremely careless.
