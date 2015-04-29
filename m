From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 2/2] tcp: add TCP_CC_INFO socket option
Date: Tue, 28 Apr 2015 21:00:06 -0400
Message-ID: <CADVnQymQwo-teVfqos5M0yFVF_AZarv+BUQJRscz9kHs9x6scg@mail.gmail.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	<1430263429-4069-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33358 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031166AbbD2BAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 21:00:06 -0400
Received: by oblw8 with SMTP id w8so9599982obl.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 18:00:06 -0700 (PDT)
In-Reply-To: <1430263429-4069-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 7:23 PM, Eric Dumazet <edumazet@google.com> wrote:
> Some Congestion Control modules can provide per flow information,
> but current way to get this information is to use netlink.
>
> Like TCP_INFO, let's add TCP_CC_INFO so that applications can
> issue a getsockopt() if they have a socket file descriptor,
> instead of playing complex netlink games.
>
> Sample usage would be :
>
>   union tcp_cc_info info;
>   socklen_t len = sizeof(info);
>
>   if (getsockopt(fd, SOL_TCP, TCP_CC_INFO, &info, &len) == -1)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

A very useful facility. Thanks for putting this together, Eric!

neal
