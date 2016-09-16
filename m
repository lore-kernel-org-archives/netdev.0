From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 02/14] tcp: use windowed min filter library for
 TCP min_rtt estimation
Date: Fri, 16 Sep 2016 15:25:28 -0400
Message-ID: <CADVnQym_m_OkQdMCYJo=UqtjRqoEA2btEwWnVY7t4hVftcc3TA@mail.gmail.com>
References: <1474051743-13311-3-git-send-email-ncardwell@google.com> <201609170308.dReNRIGl%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35266 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933595AbcIPT0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:26:00 -0400
Received: by mail-oi0-f42.google.com with SMTP id w11so123530177oia.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:26:00 -0700 (PDT)
In-Reply-To: <201609170308.dReNRIGl%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 3:21 PM, kbuild test robot <lkp@intel.com> wrote:
> All errors (new ones prefixed by >>):
>
>>> net/ipv4/tcp_cdg.c:59:8: error: redefinition of 'struct minmax'
>     struct minmax {
>            ^~~~~~
>    In file included from include/linux/tcp.h:22:0,
>                     from include/net/tcp.h:24,
>                     from net/ipv4/tcp_cdg.c:30:
>    include/linux/win_minmax.h:17:8: note: originally defined here
>     struct minmax {
>            ^~~~~~
>
> vim +59 net/ipv4/tcp_cdg.c

Sorry about that. I will fix that and re-post.

neal
