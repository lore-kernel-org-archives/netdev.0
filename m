From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 6/8] ipv6: process socket-level control messages
 in IPv6
Date: Wed, 30 Mar 2016 23:37:21 -0400
Message-ID: <CAF=yD-KD9xp9Wvk9ShL+G6H5+_OZ2-yTY33dQBWU+Anvowc27g@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com> <1459377448-2239-7-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33873 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbcCaDiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 23:38:02 -0400
Received: by mail-lf0-f68.google.com with SMTP id f127so6943878lff.1
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 20:38:01 -0700 (PDT)
In-Reply-To: <1459377448-2239-7-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 6:37 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> Process socket-level control messages by invoking
> __sock_cmsg_send in ip6_datagram_send_ctl for control messages on
> the SOL_SOCKET layer.
>
> This makes sure whenever ip6_datagram_send_ctl is called for
> udp and raw, we also process socket-level control messages.
>
> This is a bit uglier than IPv4, since IPv6 does not have
> something like ipcm_cookie. Perhaps we can later create
> a control message cookie for IPv6?
>
> Note that this commit interprets new control messages that
> were ignored before. As such, this commit does not change
> the behavior of IPv6 control messages.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
