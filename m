From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 10/12] bna: TX Queue Depth Fix
Date: Wed, 31 Aug 2011 06:46:00 +0200
Message-ID: <1314765960.11043.3.camel@edumazet-laptop>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
	 <1314754068-31978-11-git-send-email-rmody@brocade.com>
	 <1314764670.2556.23.camel@edumazet-laptop>
	 <CAA93jw7OrqruzEu4EzEubqFdKpLrkPN9ksh5SSqU5pVcSCjgcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rasesh Mody <rmody@brocade.com>, davem@davemloft.net,
	netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63412 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab1HaEqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 00:46:08 -0400
Received: by wyg24 with SMTP id 24so222924wyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 21:46:06 -0700 (PDT)
In-Reply-To: <CAA93jw7OrqruzEu4EzEubqFdKpLrkPN9ksh5SSqU5pVcSCjgcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 21:34 -0700, Dave Taht a =C3=A9crit :
> On Tue, Aug 30, 2011 at 9:24 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> > BNAD_MAX_Q_DEPTH is now defined but not used.
> >
> > BTW, 32768 slots in a RX queue is insane.
>=20
> As that is many lunar distances worth of buffering... Are they
> expecting transmissions from mars?
>=20

At 10GB rate, this can be filled in ~2msec with small frames.

Apparently some people business depend on not losing frames.

But they should be warned of extra memory needs, and latency increases
(because of a larger working set)
