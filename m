From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 1/1] net: tcp: RTO restart
Date: Wed, 19 Feb 2014 21:09:13 +0100
Message-ID: <B4E31628-4269-46E2-ADEF-4F3A5F68FD69@simula.no>
References: <20140218181205.GA7780@kau.se> <50334B08-CD60-4C4C-9556-ACC758F75D7E@simula.no> <1392832907.18849.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Per Hurtig <per.hurtig@kau.se>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com,
	=?windows-1252?Q?Anna_Brunstr=F6m?= <anna.brunstrom@kau.se>,
	Michael Welzl <michawe@ifi.uio.no>, ilpo.jarvinen@helsinki.fi
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:34479 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569AbaBSUJU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 15:09:20 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.75)
	(envelope-from <apetlund@simula.no>)
	id 1WGDSH-0004eL-U9
	for netdev@vger.kernel.org; Wed, 19 Feb 2014 21:09:17 +0100
In-Reply-To: <1392832907.18849.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=20
On 19 Feb 2014, at 19:01, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-02-19 at 18:17 +0100, Andreas Petlund wrote:
>> I=92ve applied and tested the patch on VMs with both 32 bit and 64 b=
it kernel.
>>=20
>> Acked-by: Andreas Petlund <apetlund@simula.no>
>> Tested-by: Andreas Petlund <apetlund@simula.no>
>=20
> Sure the patch applies, but what experimental results did you get ?
>=20
> My concern is that TCP_SKB_CB(skb)->when doesn't account for sojourn
> time in host queues (qdisc and device).=20
>=20

Thank=92s for the input. I didn=92t run any specific tests with that in=
 mind. I=92ll look into it.

Best regards,
Andreas
