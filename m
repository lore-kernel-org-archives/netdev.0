From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 05/14] tcp: track data delivery rate for a TCP connection
Date: Sat, 17 Sep 2016 08:09:16 -0400
Message-ID: <CADVnQykMAMzGn5yi5Zz-R_XwRMRneGDJhv-cYGceG8z6-AWTGw@mail.gmail.com>
References: <1474051743-13311-6-git-send-email-ncardwell@google.com> <201609170509.mUNO6Hq1%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33296 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753234AbcIQMJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 08:09:48 -0400
Received: by mail-oi0-f49.google.com with SMTP id r126so140777613oib.0
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 05:09:48 -0700 (PDT)
In-Reply-To: <201609170509.mUNO6Hq1%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 5:38 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Yuchung,
>
> [auto build test WARNING on net-next/master]
> All warnings (new ones prefixed by >>):
>
>    In file included from net/ipv4/route.c:103:0:
>>> include/net/tcp.h:769:11: warning: 'packed' attribute ignored for field of type 'struct skb_mstamp' [-Wattributes]
>        struct skb_mstamp first_tx_mstamp __packed;
>               ^~~~~~~~~~
>    include/net/tcp.h:771:11: warning: 'packed' attribute ignored for field of type 'struct skb_mstamp' [-Wattributes]
>        struct skb_mstamp delivered_mstamp __packed;
>               ^~~~~~~~~~

We have a fix for this, and we'll post it with the v2 series.

thanks,
neal
