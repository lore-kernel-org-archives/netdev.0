From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Tue, 07 Sep 2010 11:37:28 +0200
Message-ID: <1283852248.2338.160.camel@edumazet-laptop>
References: <20100907091614.GA8245@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58625 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756112Ab0IGJhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 05:37:33 -0400
Received: by fxm13 with SMTP id 13so2855797fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 02:37:32 -0700 (PDT)
In-Reply-To: <20100907091614.GA8245@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 09:16 +0000, Jarek Poplawski a =C3=A9=
crit :
> On 2010-09-07 07:02, Eric Dumazet wrote:

> >=20
> > I understand what you want to do, but problem is we need to perform=
 a
> > CAS2 operation : atomically changes two values (dataref and frag_li=
st)
>=20
> Alas I can't understand why do you think these clone and atomic tests
> in skb_release_data() don't protect skb_shinfo(skb)->frag_list enough=
=2E
>=20

It was early in the morning, before a cup of tea.

David only had to set frag_list in the new shinfo, not the old.



