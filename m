From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] skbtrace v2: core feature and common events
Date: Fri, 19 Oct 2012 09:10:47 +0200
Message-ID: <1350630647.2293.194.camel@edumazet-glaptop>
References: <5080F031.5040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33551 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab2JSHKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 03:10:51 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so47067bkc.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 00:10:50 -0700 (PDT)
In-Reply-To: <5080F031.5040804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 14:16 +0800, Li Yu wrote:
> From: Li Yu <bingtian.ly@taobao.com>
> 
> This patch contains:
> 
> 1. The glue code of tracepoints subsystem and relay file system.
> 2. API for particular networking trace points.
> 3. The skb_rps_info trace point.
> 
> Thanks
> 
> Sign-off-by: Li Yu <bingtian.ly@taobao.com>
> 
>  include/linux/skbtrace.h               |  478 ++++++++++++
>  include/linux/skbtrace_api.h           |   73 +
>  include/linux/skbuff.h                 |    7
>  include/net/skbtrace_api_common.h      |   84 ++
>  include/net/sock.h                     |   14
>  include/trace/events/skbtrace.h        |   32
>  include/trace/events/skbtrace_common.h |   41 +
>  kernel/trace/Kconfig                   |    8
>  net/core/Makefile                      |    2
>  net/core/dev.c                         |    3
>  net/core/net-traces.c                  |   24
>  net/core/skbtrace-core.c               | 1226
> +++++++++++++++++++++++++++++++++
>  net/core/skbtrace-events-common.c      |   68 +
>  net/core/skbuff.c                      |    5
>  net/core/sock.c                        |    9
>  15 files changed, 2073 insertions(+), 1 deletion(-)


Hi

Three months ago I gave my feedback about all this.

And I dont think there is any real answer to my questions.

There is 0 documentation, 0 example of how many bugs you found and fixed
thanks to this huge patch.

Please fix a dozen of bugs with it, then we will be convinced it might
be needed to review 2000 LOC

Thanks
