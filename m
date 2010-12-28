From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: add performance flags to
 dev->features
Date: Wed, 29 Dec 2010 00:07:09 +0100
Message-ID: <20101228230709.GA2088@del.dom.local>
References: <20101220130247.GB9325@ff.dom.local>
 <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
 <1292855120.2800.45.camel@edumazet-laptop>
 <20101228.135013.39173075.davem@davemloft.net>
 <1293575781.20573.391.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	pstaszewski@itcare.pl, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57110 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab0L1XHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 18:07:15 -0500
Received: by bwz15 with SMTP id 15so10558548bwz.19
        for <netdev@vger.kernel.org>; Tue, 28 Dec 2010 15:07:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1293575781.20573.391.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 28, 2010 at 11:36:21PM +0100, Eric Dumazet wrote:
> Le mardi 28 d=E9cembre 2010 ?? 13:50 -0800, David Miller a =E9crit :
>=20
> > Changli has suggested that these flags can also be set in
> > ->vlan_features, please address that if you expect me to
> > apply the change.
>=20
> Hmm, I am just scratching my head to actually setup vlans on top of i=
fb,
> to test such a change ?

Ingress is before vlans handler so these features and the
NETIF_F_HW_VLAN_TX flag seem useful for ifb considering
dev_hard_start_xmit() checks.

Jarek P.
