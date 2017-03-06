From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp on
 tpacket_v3 in tx mode
Date: Mon, 6 Mar 2017 09:13:29 -0800
Message-ID: <CAAsGZS59KsGHJzG-U962kK4AP+M40zAV-ERgDqYvDLz5JB6Exg@mail.gmail.com>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net>
 <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com> <586E9A0F.1020002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        sowmini.varadhan@oracle.com, willemb@google.com,
        netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35453 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753041AbdCFRkq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 12:40:46 -0500
Received: by mail-ua0-f171.google.com with SMTP id q7so139810046uaf.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 09:40:45 -0800 (PST)
In-Reply-To: <586E9A0F.1020002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> Gosh. Can we also replace this BUG() into something less aggressive ?
>
>
> There are currently 5 of these WARN() + BUG() constructs and 1 BUG()-only
> for the 'default' TPACKET version spread all over af_packet, so probably
> makes sense to rather make all of them less aggressive.
>
>

Very few consumers actually go looking in the kernel logs to see the
error-warnings and report them back here.

This severity will get them to report the incident which in this case
got fixed??
