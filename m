From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-stable 3.3..3.12] inet_diag: fix
 inet_diag_dump_icsk() timewait socket state logic
Date: Sun, 02 Feb 2014 19:54:17 -0800
Message-ID: <1391399657.28432.93.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391391613-687-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:38838 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689AbaBCDyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Feb 2014 22:54:19 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so6563328pbc.2
        for <netdev@vger.kernel.org>; Sun, 02 Feb 2014 19:54:19 -0800 (PST)
In-Reply-To: <1391391613-687-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-02 at 20:40 -0500, Neal Cardwell wrote:
...
> An analogous fix is in v3.13: 70315d22d3c7383f9a508d0aab21e2eb35b2303a
> ("inet_diag: fix inet_diag_dump_icsk() to use correct state for
> timewait sockets") but that patch is quite different because 3.13 code
> is very different in this area due to the unification of TCP hash
> tables in 05dbc7b ("tcp/dccp: remove twchain") in v3.13-rc1.
...
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/inet_diag.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
