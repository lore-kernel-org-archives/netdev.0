From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Mon, 23 Aug 2010 21:37:25 -0700
Message-ID: <AANLkTi=8oDhAr9hui3-hoxYC9LG3Lzy5r6-2L_JLsvi3@mail.gmail.com>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
	<20100824003143.243eb046.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:13067 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab0HXEh3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 00:37:29 -0400
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o7O4bRmt018564
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 21:37:28 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by hpaq14.eem.corp.google.com with ESMTP id o7O4bPjb018205
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 21:37:26 -0700
Received: by pvg2 with SMTP id 2so2429308pvg.5
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 21:37:25 -0700 (PDT)
In-Reply-To: <20100824003143.243eb046.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1 byte req. and resp.
> >
> > bnx2x on 16 core AMD
> > =A0 =A0XPS (16 queues, 1 TX queue per CPU) =A0 =A0 =A0 =A01015K at =
99% CPU
> > =A0 =A0No XPS (16 queues) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1127K at =
98% CPU
>
> I don't grok your performance numbers. =A0What do the 1015K and 1127K
> numbers represent? =A0I was originally guessing that they were basica=
lly
> transactions per second, but that would seem to imply that the No XPS
> case was better. =A0Please clarify.
>
Yes, TPS and the numbers were switched... XPS case was better!

Thanks for pointing that out.

Tom

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0-Thanks
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0-Bill
