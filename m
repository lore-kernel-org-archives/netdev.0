From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH v2 net-next 3/4] tcp: Adjust TCP ULP to defer to sockets ULP
Date: Wed, 2 Aug 2017 12:03:40 -0700
Message-ID: <CAPDqMerciSa+z2GTckgB0vXR5H=KhMLeUV4KtO9wX_85XqZ0XA@mail.gmail.com>
References: <20170802031846.21993-1-tom@quantonium.net> <20170802031846.21993-4-tom@quantonium.net>
 <20170802185908.GA47485@apz-mbp.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Rohit LastName <rohit@quantonium.net>
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37134 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHBTDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 15:03:42 -0400
Received: by mail-wm0-f43.google.com with SMTP id t201so363477wmt.0
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 12:03:42 -0700 (PDT)
In-Reply-To: <20170802185908.GA47485@apz-mbp.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 2, 2017 at 11:59 AM, Dave Watson <davejwatson@fb.com> wrote:
> On 08/01/17 08:18 PM, Tom Herbert wrote:
>> Fix TCP and TLS to use the newer ULP infrastructure in sockets.
>>
>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>> ---
>>  Documentation/networking/tls.txt   |   6 +-
>>  include/net/inet_connection_sock.h |   4 --
>>  include/net/tcp.h                  |  25 -------
>>  include/net/tls.h                  |   4 +-
>>  net/ipv4/sysctl_net_ipv4.c         |   9 ++-
>>  net/ipv4/tcp.c                     |  40 ++++++-----
>>  net/ipv4/tcp_ipv4.c                |   2 -
>>  net/ipv4/tcp_ulp.c                 | 135 -------------------------------------
>>  net/tls/Kconfig                    |   1 +
>>  net/tls/tls_main.c                 |  21 +++---
>>  10 files changed, 47 insertions(+), 200 deletions(-)
>>  delete mode 100644 net/ipv4/tcp_ulp.c
>
> It looks like net/ipv4/Makefile needs updating as well.
>
Right, I'll send out v3.

> I ran this through some ktls tests with no issues.  Thanks
>
> Tested-by: Dave Watson <davejwatson@fb.com>

Thanks for testing!

Tom
