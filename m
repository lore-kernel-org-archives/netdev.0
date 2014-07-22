From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: Fix integer-overflows in TCP vegas
Date: Tue, 22 Jul 2014 17:58:40 -0400
Message-ID: <CADVnQymL5ns=N8iQHZSvPitbbTpatnWTgPs+M0QxpiyL9FJ5Ug@mail.gmail.com>
References: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Doug Leith <doug.leith@nuim.ie>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:65468 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbaGVV6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 17:58:41 -0400
Received: by mail-we0-f181.google.com with SMTP id k48so291599wev.12
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 14:58:40 -0700 (PDT)
In-Reply-To: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 5:36 PM, Christoph Paasch
<christoph.paasch@uclouvain.be> wrote:
> In vegas we do a multiplication of the cwnd and the rtt. This
> may overflow and thus their result is stored in a u64. However, we first
> need to cast the cwnd so that actually 64-bit arithmetic is done.
>
> Cc: Doug Leith <doug.leith@nuim.ie>
> Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv4/tcp_vegas.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks!

neal
