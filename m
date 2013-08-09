From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: add server ip to encrypt cookie in fast open
Date: Thu, 8 Aug 2013 20:48:28 -0400
Message-ID: <CADVnQynQZDzefMWX868c46i0RkuRig=6By1B70a9=2GWTkcDfA@mail.gmail.com>
References: <1375995982-17862-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:58170 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966976Ab3HIAs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 20:48:29 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so1823814eek.14
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 17:48:28 -0700 (PDT)
In-Reply-To: <1375995982-17862-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 8, 2013 at 5:06 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Encrypt the cookie with both server and client IPv4 addresses,
> such that multi-homed server will grant different cookies
> based on both the source and destination IPs. No client change
> is needed since cookie is opaque to the client.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/net/tcp.h       |  3 ++-
>  net/ipv4/tcp_fastopen.c | 13 ++++++-------
>  net/ipv4/tcp_ipv4.c     | 10 +++++++---
>  3 files changed, 15 insertions(+), 11 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>
