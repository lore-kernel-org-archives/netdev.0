From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IFF_TX_SKB_SHARING
Date: Wed, 14 Sep 2011 13:46:15 +0200
Message-ID: <1316000775.2361.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <Pine.NEB.4.64.1109141227580.19629@otaku.Xtrmntr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: Pekka Riikonen <priikone@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49931 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289Ab1INLqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 07:46:09 -0400
Received: by bkbzt4 with SMTP id zt4so1457610bkb.19
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2011 04:46:08 -0700 (PDT)
In-Reply-To: <Pine.NEB.4.64.1109141227580.19629@otaku.Xtrmntr.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 septembre 2011 =C3=A0 12:38 +0200, Pekka Riikonen a =C3=A9=
crit :
> The IFF_TX_SKB_SHARING flag was introduced in d88733150.  Was it inte=
nded=20
> that it clears IFF_XMIT_DST_RELEASE flag?  It's set in alloc_netdev_m=
qs=20
> but gets cleared by ether_setup (via alloc_etherdev_mqs).
>=20

Good catch, thanks Pekka
