From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Tue, 20 Sep 2016 16:39:06 -0700
Message-ID: <20160920163906.7c6d69fe@xeon-e3>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
        <1474342763-16715-17-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35253 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbcITXi4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:38:56 -0400
Received: by mail-pa0-f41.google.com with SMTP id oz2so11669733pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:38:56 -0700 (PDT)
In-Reply-To: <1474342763-16715-17-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
> enabled, since pacing is integral to the BBR design and
> implementation. BBR without pacing would not function properly, and
> may incur unnecessary high packet loss rates.

Does it work with fq_codel?
