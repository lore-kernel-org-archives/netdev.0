From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: avoid possible arithmetic overflows
Date: Mon, 22 Sep 2014 13:28:42 -0700
Message-ID: <1411417722.26859.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAK6E8=d9y8D5we_fibzxstaXBMnQcOG3DsOAL0jhzDGK1H62cw@mail.gmail.com>
	 <1411389739.26859.113.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411417184.26859.147.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140922.162703.824025819934075774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, joe@perches.com, netdev@vger.kernel.org,
	ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34440 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbaIVU2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:28:43 -0400
Received: by mail-pa0-f41.google.com with SMTP id ey11so5837404pad.28
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 13:28:43 -0700 (PDT)
In-Reply-To: <20140922.162703.824025819934075774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-22 at 16:27 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 22 Sep 2014 13:19:44 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > icsk_rto is a 32bit field, and icsk_backoff can reach 15 by default,
> > or more if some sysctl (eg tcp_retries2) are changed.
> > 
> > Better use 64bit to perform icsk_rto << icsk_backoff operations
> > 
> > As Joe Perches suggested, add a helper for this.
> > 
> > Yuchung spotted the tcp_v4_err() case.
> > 
> > From: Eric Dumazet <edumazet@google.com>
> 
> I assume you meant "Signed-off-by: " on that last line, not "From: " :-)
> 
> Applied,

Arg, thanks David ;)
