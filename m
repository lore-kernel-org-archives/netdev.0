From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/3] net: Byte queue limit patch series
Date: Tue, 26 Apr 2011 08:17:41 +0200
Message-ID: <1303798661.2747.209.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
	 <20110426015645.c2d19cfe.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:54564 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077Ab1DZGRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 02:17:47 -0400
Received: by wwk4 with SMTP id 4so1913143wwk.1
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 23:17:46 -0700 (PDT)
In-Reply-To: <20110426015645.c2d19cfe.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 01:56 -0400, Bill Fink a =C3=A9crit :

> I don't quite follow your conclusion from your data.
> While there was a sweet spot for the 1400 rr size, other
> smaller rr took a hit.  Now all the tps changes were
> within 1 %, so perhaps that isn't considered significant
> (I'm not qualified to make that call).  But if that's
> the case, then the effective latency change seen by the
> user isn't significant either, although the amount of
> queuing in the NIC is admittedly significantly reduced
> for a rr size of 1400 or larger.

Tom point was to show that we can reduce latency (because size of
netdevice queue is smaller) without changing tps ;)



