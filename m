From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 12:03:32 -0400
Message-ID: <CADVnQy=sC+o9EOT2cXvuy2zwW_MS+czw5yZG_119Q1ePUKmvhw@mail.gmail.com>
References: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36679 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706AbbEZQDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 12:03:33 -0400
Received: by oihb142 with SMTP id b142so81291625oih.3
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:03:33 -0700 (PDT)
In-Reply-To: <1432655728.4060.257.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 11:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> By making sure sk->sk_gso_max_segs minimal value is one,
> and sysctl_tcp_min_tso_segs minimal value is one as well,
> tcp_tso_autosize() will return a non zero value.
>
> We can then revert 843925f33fcc293d80acf2c5c8a78adf3344d49b
> ("tcp: Do not apply TSO segment limit to non-TSO packets")
> and save few cpu cycles in fast path.

Thanks, Eric! This is a nice clean-up/simplification.

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
