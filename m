From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 07/11] fs_enet: enable transmit time stamping.
Date: Mon, 20 Jun 2011 08:58:31 +0200
Message-ID: <20110620065831.GA5771@riccoc20.at.omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
 <2a8677b99c6b8d0e34bbf0f6d6a44e6c7992636d.1308481492.git.richard.cochran@omicron.at>
 <1308484684.3539.76.camel@edumazet-laptop>
 <20110619181212.GA3594@riccoc20.at.omicron.at>
 <1308508249.3539.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59566 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab1FTG62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 02:58:28 -0400
Received: by fxm17 with SMTP id 17so739173fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 23:58:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1308508249.3539.78.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2011 at 08:30:49PM +0200, Eric Dumazet wrote:
> Le dimanche 19 juin 2011 =E0 20:12 +0200, Richard Cochran a =E9crit :
>=20
> > Thanks for your review. I have posted a fix for the first batch (si=
nce
> > they are already in next) and reposted this series.
> >=20
> > But, considering your point, it looks like pxa168_eth and mv643xx_e=
th
> > (see patches 9 and 10 of this series) already access skb->len unsaf=
ely.
> >=20
> > Would you care to comment on those spots, too?
>=20
> They certainly are buggy, at a first glance.
>=20
> Not only skb->len is unsafe, but netif_tx_stop_queue() calls are unsa=
fe
> too.

Out of the MAC drivers in my two batches, only drivers/net/tg3.c calls
netif_tx_stop_queue(txq);

However, I don't know how to fix that. Anyone else care to take a look?

Thanks,

Richard
