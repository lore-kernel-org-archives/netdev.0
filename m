From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 11/11] tcp: rate limit ACK sent by SYN_RECV
 request sockets
Date: Fri, 1 Apr 2016 12:05:20 -0400
Message-ID: <CADVnQy=bR=zWiDwyrzjaJ9qHSeJJ7mAUvoxgQ57AgG-VK5wtaw@mail.gmail.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
	<1459525942-30399-12-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:35187 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbcDAQFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 12:05:21 -0400
Received: by mail-ob0-f177.google.com with SMTP id fp4so50014836obb.2
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 09:05:20 -0700 (PDT)
In-Reply-To: <1459525942-30399-12-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016 at 11:52 AM, Eric Dumazet <edumazet@google.com> wrote:
> Attackers like to use SYNFLOOD targeting one 5-tuple, as they
> hit a single RX queue (and cpu) on the victim.
>
> If they use random sequence numbers in their SYN, we detect
> they do not match the expected window and send back an ACK.
>
> This patch adds a rate limitation, so that the effect of such
> attacks is limited to ingress only.
>
> We roughly double our ability to absorb such attacks.

Thanks, Eric!

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
