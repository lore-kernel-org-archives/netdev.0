From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 net-next 1/2] net: add sk_stream_is_writeable() helper
Date: Tue, 23 Jul 2013 09:52:07 -0400
Message-ID: <CADVnQymsab6+EUJKuuo_szB+EuzqaHs8i05eqaH6YG10ttOURA@mail.gmail.com>
References: <1374549991.4990.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	Yuchung Cheng <ycheng@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:43374 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433Ab3GWNwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 09:52:08 -0400
Received: by mail-ee0-f49.google.com with SMTP id b57so4493592eek.22
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 06:52:07 -0700 (PDT)
In-Reply-To: <1374549991.4990.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 11:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Several call sites use the hardcoded following condition :
>
> sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)
>
> Lets use a helper because TCP_NOTSENT_LOWAT support will change this
> condition for TCP sockets.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
