From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Tue, 20 Sep 2016 19:42:00 -0400
Message-ID: <CADVnQymgWrzxLSE8r9pE_fOcXLbg+QTMco7grZnmPH2EVre=pw@mail.gmail.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
 <1474342763-16715-17-git-send-email-ncardwell@google.com> <20160920163906.7c6d69fe@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35261 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754679AbcITXmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:42:32 -0400
Received: by mail-oi0-f52.google.com with SMTP id w11so41327778oia.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:42:32 -0700 (PDT)
In-Reply-To: <20160920163906.7c6d69fe@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 7:39 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>> NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
>> enabled, since pacing is integral to the BBR design and
>> implementation. BBR without pacing would not function properly, and
>> may incur unnecessary high packet loss rates.
>
> Does it work with fq_codel?

Good question. Since fq_codel does not (currently) implement pacing,
it would not be sufficient to get the required behavior.

neal
