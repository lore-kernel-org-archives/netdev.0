From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: avoid setting cwnd to invalid ssthresh after
 cwnd reduction states
Date: Wed, 02 Aug 2017 02:07:23 -0700
Message-ID: <1501664843.25002.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170801202232.162176-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com,
        edumazet@google.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35782 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdHBJH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 05:07:26 -0400
Received: by mail-wm0-f44.google.com with SMTP id m85so35783296wma.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 02:07:26 -0700 (PDT)
In-Reply-To: <20170801202232.162176-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-01 at 13:22 -0700, Yuchung Cheng wrote:
> If the sender switches the congestion control during ECN-triggered
> cwnd-reduction state (CA_CWR), upon exiting recovery cwnd is set to
> the ssthresh value calculated by the previous congestion control. If
> the previous congestion control is BBR that always keep ssthresh
> to TCP_INIFINITE_SSTHRESH, cwnd ends up being infinite. The safe
> step is to avoid assigning invalid ssthresh value when recovery ends.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_input.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
