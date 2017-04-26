From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast open using experimental TCP option?
Date: Tue, 25 Apr 2017 17:13:56 -0700
Message-ID: <1493165636.6453.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALx6S36L4BbdcASbGNvn6mRMJDhJJ6n8y-uRTgVqteM=f6On6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jerry Chu <hkchu@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35499 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1431776AbdDZAOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 20:14:09 -0400
Received: by mail-pf0-f174.google.com with SMTP id v14so29813292pfd.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 17:14:09 -0700 (PDT)
In-Reply-To: <CALx6S36L4BbdcASbGNvn6mRMJDhJJ6n8y-uRTgVqteM=f6On6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-25 at 12:08 -0700, Tom Herbert wrote:
> Looks like TCP fast open was using experimental TCP option at some. Is
> this still needed? Technically this violates usage requirements of
> experimental options. Can this be removed now since there is now an
> assigned option number for TFO?
> 
>                              case TCPOPT_EXP:
>                                 /* Fast Open option shares code 254 using a
>                                  * 16 bits magic number.
>                                  */
>                                 if (opsize >= TCPOLEN_EXP_FASTOPEN_BASE &&
>                                     get_unaligned_be16(ptr) ==
>                                     TCPOPT_FASTOPEN_MAGIC)
>                                         tcp_parse_fastopen_option(opsize -
>                                                 TCPOLEN_EXP_FASTOPEN_BASE,
>                                                 ptr + 2, th->syn, foc, true);
>                                 break;

Hi Tom

Client side was updated in linux-4.1 only two years ago.

We lack counters telling how often the experimental option is used.

RFC6994 ( 5.  Migration to Assigned Options ) guidelines are properly
met.

Not sure why we should hurry ?
