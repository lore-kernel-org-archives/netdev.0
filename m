From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix tcp_grow_window() for large incoming frames
Date: Tue, 17 Apr 2012 08:40:18 -0400
Message-ID: <CADVnQy=fDvcetb+FaS4ShrZ4mi9v0TpKk0aVqeQvV_En43gsWQ@mail.gmail.com>
References: <1334654887.2472.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:36675 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756023Ab2DQMkT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 08:40:19 -0400
Received: by qcro28 with SMTP id o28so3772840qcr.19
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 05:40:18 -0700 (PDT)
In-Reply-To: <1334654887.2472.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 5:28 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> tcp_grow_window() has to grow rcv_ssthresh up to window_clamp, allowi=
ng
> sender to increase its window.
>
> tcp_grow_window() still assumes a tcp frame is under MSS, but its no
> longer true with LRO/GRO.
>
> This patch fixes one of the performance issue we noticed with GRO on.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
> Sorry for the delay, this was discussed a long time ago.
>
> =A0net/ipv4/tcp_input.c | =A0 =A01 +
> =A01 file changed, 1 insertion(+)

Acked-by: Neal Cardwell <ncardwell@google.com>
