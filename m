From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: timestamp SYN+DATA messages
Date: Mon, 10 Mar 2014 12:22:49 -0400
Message-ID: <CADVnQy=ah3JAeTbsqOf_-T-45UdjXMHV1=r=GLiELThH1qS-uQ@mail.gmail.com>
References: <1394411762.20149.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:59261 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbaCJQWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 12:22:50 -0400
Received: by mail-ee0-f51.google.com with SMTP id c13so3195707eek.24
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 09:22:49 -0700 (PDT)
In-Reply-To: <1394411762.20149.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 9, 2014 at 8:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> All skb in socket write queue should be properly timestamped.
>
> In case of FastOpen, we special case the SYN+DATA 'message' as we
> queue in socket wrote queue the two fallback skbs:
>
> 1) SYN message by itself.
> 2) DATA segment by itself.
>
> We should make sure these skbs have proper timestamps.
>
> Add a WARN_ON_ONCE() to eventually catch future violations.
>
> Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
