From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net-next: remove useless union keyword
Date: Mon, 03 May 2010 09:44:07 +0200
Message-ID: <1272872647.2226.8.camel@edumazet-laptop>
References: <1272837206-13223-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50834 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105Ab0ECHoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 03:44:11 -0400
Received: by bwz19 with SMTP id 19so1128568bwz.21
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 00:44:09 -0700 (PDT)
In-Reply-To: <1272837206-13223-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 mai 2010 =C3=A0 05:53 +0800, Changli Gao a =C3=A9crit :
> remove useless union keyword in rtable, rt6_info and dn_route.
>=20
> Since there is only one member in a union, the union keyword isn't us=
eful.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----


Thats right, in 2.6.20, next pointer was relocalised at the end of
'struct dst_entry' in commits 093c2ca4167cf66f69020329d14138da0da8599b
and 1e19e02ca0c5e33ea73a25127dbe6c3b8fcaac4b

The union trick is only needed in 'struct dst_entry'.

Please respin your patch against net-next-2.6

patching file net/ipv6/ip6_output.c
Hunk #1 succeeded at 701 (offset 1 line).
Hunk #3 succeeded at 743 (offset 1 line).
Hunk #5 succeeded at 788 (offset 1 line).
Hunk #7 succeeded at 1159 (offset 1 line).
Hunk #9 succeeded at 1227 (offset 1 line).
Hunk #11 succeeded at 1284 (offset 1 line).
Hunk #13 succeeded at 1506 (offset 1 line).


