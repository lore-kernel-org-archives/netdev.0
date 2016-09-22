From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix under-accounting retransmit SNMP counters
Date: Wed, 21 Sep 2016 19:19:16 -0700
Message-ID: <1474510756.23058.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474499775-26436-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33809 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752070AbcIVCTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 22:19:18 -0400
Received: by mail-pf0-f181.google.com with SMTP id p64so25141387pfb.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 19:19:18 -0700 (PDT)
In-Reply-To: <1474499775-26436-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-21 at 16:16 -0700, Yuchung Cheng wrote:
> This patch fixes these under-accounting SNMP rtx stats
> LINUX_MIB_TCPFORWARDRETRANS
> LINUX_MIB_TCPFASTRETRANS
> LINUX_MIB_TCPSLOWSTARTRETRANS
> when retransmitting TSO packets
> 
> Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Good catch, thanks Yuchung !

Acked-by: Eric Dumazet <edumazet@google.com>
