From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net] tcp: consider recv buf for the initial window scale
Date: Fri, 29 Jul 2016 09:39:15 -0400
Message-ID: <CADVnQy=VeCdeaTBCe7ighw-CoT6bP4Ve2aFvB0gsAesHVUmnYw@mail.gmail.com>
References: <1469799242-28408-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35365 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbcG2Njq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 09:39:46 -0400
Received: by mail-oi0-f43.google.com with SMTP id l72so106573659oig.2
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 06:39:45 -0700 (PDT)
In-Reply-To: <1469799242-28408-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 9:34 AM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> To fix this, consider the maximum of net.ipv4.tcp_rmem[2],
> net.core.rmem_max and socket's initial buffer space.
>
> Fixes: b0573dea1fb3 ("[NET]: Introduce SO_{SND,RCV}BUFFORCE socket options")
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Suggested-by: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Soheil.

neal
