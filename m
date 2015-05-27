From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 21:07:59 -0700
Message-ID: <1432699679.4060.341.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150526.235252.1950980875679896021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37502 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbbE0EIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 00:08:02 -0400
Received: by igbsb11 with SMTP id sb11so4970747igb.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 21:08:01 -0700 (PDT)
In-Reply-To: <20150526.235252.1950980875679896021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 23:52 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 May 2015 08:55:28 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > By making sure sk->sk_gso_max_segs minimal value is one,
> > and sysctl_tcp_min_tso_segs minimal value is one as well,
> > tcp_tso_autosize() will return a non zero value.
> > 
> > We can then revert 843925f33fcc293d80acf2c5c8a78adf3344d49b
> > ("tcp: Do not apply TSO segment limit to non-TSO packets")
> > and save few cpu cycles in fast path.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, thanks Eric.

Thanks David, and many thanks to Herbert and Neal for the reviews !
