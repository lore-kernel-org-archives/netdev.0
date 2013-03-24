From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: undo spurious timeout after SACK reneging
Date: Sun, 24 Mar 2013 16:50:41 -0400
Message-ID: <CADVnQy=koYif1cM+VuXirz26jV33zDK2KHNW=EQUfRaGqBHa+g@mail.gmail.com>
References: <1364157745-24866-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:48859 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511Ab3CXUum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 16:50:42 -0400
Received: by mail-ea0-f178.google.com with SMTP id g14so2127014eak.9
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 13:50:41 -0700 (PDT)
In-Reply-To: <1364157745-24866-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 4:42 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On SACK reneging the sender immediately retransmits and forces a
> timeout but disables Eifel (undo). If the (buggy) receiver does not
> drop any packet this can trigger a false slow-start retransmit storm
> driven by the ACKs of the original packets. This can be detected with
> undo and TCP timestamps.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
