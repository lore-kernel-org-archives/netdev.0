From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 1/5] tcp: move fastopen functions to tcp_fastopen.c
Date: Mon, 12 May 2014 15:16:01 -0400
Message-ID: <CADVnQymyG86LDsZokNS0u02cnWc-m_DGChBF3x40M7kANvfWyg@mail.gmail.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
	<1399864933-28287-2-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, longinus00@gmail.com,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38880 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaELTQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 15:16:03 -0400
Received: by mail-wi0-f170.google.com with SMTP id bs8so6009345wib.5
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 12:16:01 -0700 (PDT)
In-Reply-To: <1399864933-28287-2-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 11:22 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Move common TFO functions that will be used by both v4 and v6
> to tcp_fastopen.c. Create a helper tcp_fastopen_queue_check().
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Daniel Lee <longinus00@gmail.com>
> Signed-off-by: Jerry Chu <hkchu@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/net/tcp.h       |  10 ++-
>  net/ipv4/tcp_fastopen.c | 190 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_ipv4.c     | 185 +---------------------------------------------
>  3 files changed, 200 insertions(+), 185 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
