From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the
 passive open side
Date: Wed, 08 Jun 2011 23:03:25 +0200
Message-ID: <1307567005.3980.1.camel@edumazet-laptop>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
	 <BANLkTimXgK03tM1e3FYe+wausHT15W6H-2eMNCWaj8LLxRvbZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41251 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab1FHVD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 17:03:29 -0400
Received: by wya21 with SMTP id 21so673273wya.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 14:03:28 -0700 (PDT)
In-Reply-To: <BANLkTimXgK03tM1e3FYe+wausHT15W6H-2eMNCWaj8LLxRvbZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 juin 2011 =C3=A0 11:04 -0700, Jerry Chu a =C3=A9crit :
> [resent to cc netdev]
>=20

Well, the first copy I received this morning was OK ;)

But this second one is mangled by your mailer or something ?

> This patch lowers the default initRTO from 3secs to 1sec per
> RFC2988bis. It falls back to 3secs if the SYN or SYN-ACK packet
> has been retransmitted, AND the TCP timestamp option is not on.
>=20
> It also adds support to take RTT sample during 3WHS on the passive
> open side, just like its active open counterpart, and uses it, if
> valid, to seed the initRTO for the data transmission phase.
>=20
> The patch also resets ssthresh to its initial default at the
> beginning of the data transmission phase, and reduces cwnd to 1 if
> there has been MORE THAN ONE retransmission during 3WHS per RFC5681.
>=20
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> ---



