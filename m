From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: udp: add socket option to report RX queue level
Date: Fri, 17 Mar 2017 15:01:10 -0700
Message-ID: <1489788070.28631.322.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170317211312.38117-1-ckuiper@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com
To: Chris Kuiper <ckuiper@google.com>, Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35215 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751023AbdCQWCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 18:02:12 -0400
Received: by mail-pf0-f178.google.com with SMTP id x63so37406685pfx.2
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 15:01:11 -0700 (PDT)
In-Reply-To: <20170317211312.38117-1-ckuiper@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-17 at 14:13 -0700, Chris Kuiper wrote:
> This adds a new socket option "SO_RXQ_ALLOC" that enables providing
> the RX queue buffer allocation as ancillary data from the recvmsg()
> system call. The value reported is a byte number and together with
> the RX queue size (obtained via getsockopt(SO_RCVBUF) can be used to
> calculate a percentage value on how full the socket buffer is.
> ---

Seems a lot of overhead, and only UDP would be supported.

I very much prefer Josh Hunt proposal
( https://patchwork.ozlabs.org/patch/738250/ )

Ie using a separate getsockopt() call instead of adding code to UDP fast
path ?
