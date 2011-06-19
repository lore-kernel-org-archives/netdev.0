From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/11] fs_enet: enable transmit time stamping.
Date: Sun, 19 Jun 2011 20:30:49 +0200
Message-ID: <1308508249.3539.78.camel@edumazet-laptop>
References: <cover.1308481491.git.richard.cochran@omicron.at>
	 <2a8677b99c6b8d0e34bbf0f6d6a44e6c7992636d.1308481492.git.richard.cochran@omicron.at>
	 <1308484684.3539.76.camel@edumazet-laptop>
	 <20110619181212.GA3594@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56971 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609Ab1FSSa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 14:30:58 -0400
Received: by wyb38 with SMTP id 38so1229962wyb.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 11:30:57 -0700 (PDT)
In-Reply-To: <20110619181212.GA3594@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 juin 2011 =C3=A0 20:12 +0200, Richard Cochran a =C3=A9cr=
it :

> Thanks for your review. I have posted a fix for the first batch (sinc=
e
> they are already in next) and reposted this series.
>=20
> But, considering your point, it looks like pxa168_eth and mv643xx_eth
> (see patches 9 and 10 of this series) already access skb->len unsafel=
y.
>=20
> Would you care to comment on those spots, too?

They certainly are buggy, at a first glance.

Not only skb->len is unsafe, but netif_tx_stop_queue() calls are unsafe
too.

Not sure anyone still use these drivers...



