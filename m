From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the passive
 open side
Date: Wed, 8 Jun 2011 23:16:39 +0200
Message-ID: <20110608211639.GA2876@nuttenaction>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
 <BANLkTimXgK03tM1e3FYe+wausHT15W6H-2eMNCWaj8LLxRvbZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:33364 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751277Ab1FHVQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 17:16:42 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimXgK03tM1e3FYe+wausHT15W6H-2eMNCWaj8LLxRvbZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jerry

* Jerry Chu | 2011-06-08 11:04:22 [-0700]:

>+ =A0 =A0 =A0 /* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has =
been
>+ =A0 =A0 =A0 =A0* retransmitted. In light of RFC2988bis' more aggress=
ive 1sec
>+ =A0 =A0 =A0 =A0* initRTO, we only reset cwnd when more than 1 SYN/SY=
N-ACK
>+ =A0 =A0 =A0 =A0* retransmission has occurred.
>+ =A0 =A0 =A0 =A0*/
>+ =A0 =A0 =A0 if (tp->total_retrans > 1)
>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D 1;
>+ =A0 =A0 =A0 else
>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D tcp_init_cwnd(tp, dst);

Is this behavior somewhere documented? In RFC2988bis I cannot find some=
thing
similar.


Cheers, Hagen
