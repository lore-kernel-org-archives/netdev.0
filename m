From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 2/5] tcp: simplify fast open cookie processing
Date: Mon, 12 May 2014 15:23:16 -0400
Message-ID: <CADVnQym3wd8NMEFVKvSkxTQP8b7tCfPgobfhcLbF-WhZ+cGw_g@mail.gmail.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
	<1399864933-28287-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, longinus00@gmail.com,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:59127 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbaELTXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 15:23:17 -0400
Received: by mail-wi0-f180.google.com with SMTP id hi2so5077978wib.13
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 12:23:16 -0700 (PDT)
In-Reply-To: <1399864933-28287-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 11:22 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Consolidate various cookie checking and generation code to simplify
> the fast open processing. The main goal is to reduce code duplication
> in tcp_v4_conn_request() for IPv6 support.
>
> Removes two experimental sysctl flags TFO_SERVER_ALWAYS and
> TFO_SERVER_COOKIE_NOT_CHKD used primarily for developmental debugging
> purposes.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Daniel Lee <longinus00@gmail.com>
> Signed-off-by: Jerry Chu <hkchu@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/linux/tcp.h     |  5 ----
>  include/net/tcp.h       |  9 +------
>  net/ipv4/tcp_fastopen.c | 71 +++++++++++++++++++------------------------------
>  net/ipv4/tcp_ipv4.c     | 10 +++----
>  net/ipv4/tcp_output.c   |  2 +-
>  5 files changed, 33 insertions(+), 64 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
