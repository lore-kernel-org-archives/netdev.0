From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 5/8] ipv4: process socket-level control messages
 in IPv4
Date: Wed, 30 Mar 2016 23:36:55 -0400
Message-ID: <CAF=yD-LH2dzfYJmKskqVVjenjAqW4MBAe1N3tA_tO77wQMDCbg@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com> <1459377448-2239-6-git-send-email-soheil.kdev@gmail.com>
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
Received: from mail-lb0-f196.google.com ([209.85.217.196]:36208 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbcCaDhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 23:37:36 -0400
Received: by mail-lb0-f196.google.com with SMTP id q4so5828238lbq.3
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 20:37:35 -0700 (PDT)
In-Reply-To: <1459377448-2239-6-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 6:37 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> Process socket-level control messages by invoking
> __sock_cmsg_send in ip_cmsg_send for control messages on
> the SOL_SOCKET layer.
>
> This makes sure whenever ip_cmsg_send is called in udp, icmp,
> and raw, we also process socket-level control messages.
>
> Note that this commit interprets new control messages that
> were ignored before. As such, this commit does not change
> the behavior of IPv4 control messages.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
