From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 5/5] tcp: IPv6 support for fastopen server
Date: Mon, 12 May 2014 15:35:16 -0400
Message-ID: <CADVnQymUrAKbuPaQ_K=WiDYKLr1t-17UCmd9Kvd18zq4jazyXw@mail.gmail.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
	<1399864933-28287-6-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, longinus00@gmail.com,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:45264 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbaELTfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 15:35:17 -0400
Received: by mail-wi0-f177.google.com with SMTP id f8so5098823wiw.4
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 12:35:16 -0700 (PDT)
In-Reply-To: <1399864933-28287-6-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 11, 2014 at 11:22 PM, Yuchung Cheng <ycheng@google.com> wrote:
> From: Daniel Lee <longinus00@gmail.com>
>
> After all the preparatory works, supporting IPv6 in Fast Open is now easy.
> We pretty much just mirror v4 code. The only difference is how we
> generate the Fast Open cookie for IPv6 sockets. Since Fast Open cookie
> is 128 bits and we use AES 128, we use CBC-MAC to encrypt both the
> source and destination IPv6 addresses since the cookie is a MAC tag.
>
> Signed-off-by: Daniel Lee <longinus00@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Jerry Chu <hkchu@google.com>
> ---
>  net/ipv4/tcp_fastopen.c | 57 +++++++++++++++++++++++++++++++++++++------------
>  net/ipv6/tcp_ipv6.c     | 40 +++++++++++++++++++++++-----------
>  2 files changed, 71 insertions(+), 26 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
