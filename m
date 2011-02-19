From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sat, 19 Feb 2011 10:22:50 +0100
Message-ID: <1298107370.8559.24.camel@edumazet-laptop>
References: <1298039252.6201.66.camel@edumazet-laptop>
	 <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com>
	 <20110218.120656.104048936.davem@davemloft.net>
	 <20110218205832.GE2602@psychotron.redhat.com> <21593.1298070371@death>
	 <20110219080523.GB2782@psychotron.redhat.com>
	 <1298104675.8559.22.camel@edumazet-laptop>
	 <20110219085816.GC2782@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59292 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab1BSJW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 04:22:57 -0500
Received: by bwz15 with SMTP id 15so1439535bwz.19
        for <netdev@vger.kernel.org>; Sat, 19 Feb 2011 01:22:56 -0800 (PST)
In-Reply-To: <20110219085816.GC2782@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 19 f=C3=A9vrier 2011 =C3=A0 09:58 +0100, Jiri Pirko a =C3=A9c=
rit :
> Sat, Feb 19, 2011 at 09:37:55AM CET, eric.dumazet@gmail.com wrote:
> >Le samedi 19 f=C3=A9vrier 2011 =C3=A0 09:05 +0100, Jiri Pirko a =C3=A9=
crit :
> >> This patch converts bonding to use rx_handler. Results in cleaner
> >> __netif_receive_skb() with much less exceptions needed. Also
> >> bond-specific work is moved into bond code.
> >>=20
> >> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> >>=20
> >> v1->v2:
> >>         using skb_iif instead of new input_dev to remember origina=
l
> >> 	device
> >> v2->v3:
> >> 	set orig_dev =3D skb->dev if skb_iif is set
> >>=20
> >
> >Seems much better ;)
> >
> >Do you have some performance numbers ?
>=20
> I don't. I can surely obtain some. What's the best way to measure thi=
s?
>=20

Hmm, since its receive path :

Two machines, one sending (pktgen) a flood, one receiving it and
check/count how many frames hit destination, before/after patch.



