From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix SYN-data space mis-accounting
Date: Fri, 22 Feb 2013 14:23:21 -0500
Message-ID: <CADVnQy=ykmXTwNQYz=C+KjgfKr5S3UJFc-mdU6Bvdv=Gqs0e8A@mail.gmail.com>
References: <1361559546-1538-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:51412 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756139Ab3BVTXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 14:23:23 -0500
Received: by mail-ee0-f44.google.com with SMTP id l10so489768eei.17
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 11:23:22 -0800 (PST)
In-Reply-To: <1361559546-1538-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2013 at 1:59 PM, Yuchung Cheng <ycheng@google.com> wrote:
> In fast open the sender unncessarily reduces the space available
> for data in SYN by 12 bytes.  This is because in the sender
> incorrectly reserves space for TS option twice in tcp_send_syn_data():
> tcp_mtu_to_mss() already accounts for TS option space. But it further
> reserves MAX_TCP_OPTION_SPACE when computing the payload space.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
