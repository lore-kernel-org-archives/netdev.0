From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 02/13] sock: skb_copy_ubufs support for compound pages
Date: Sun, 18 Jun 2017 22:21:13 -0400
Message-ID: <CAF=yD-LwHht9etsq56ToH_ivuHReU69kVgd==1L8KKswkQz0PQ@mail.gmail.com>
References: <20170618224414.59012-3-willemdebruijn.kernel@gmail.com> <201706190955.o6jV11AS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: kbuild-all@01.org, Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Linux API <linux-api@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:34436 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753236AbdFSCVy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 22:21:54 -0400
In-Reply-To: <201706190955.o6jV11AS%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [auto build test ERROR on net-next/master]
>>    net//core/skbuff.c: In function 'skb_copy_ubufs':
>>> net//core/skbuff.c:1016:2: error: 'uarg' undeclared (first use in this function)
>      uarg->callback(uarg, false);
>      ^
>    net//core/skbuff.c:1016:2: note: each undeclared identifier is reported only once for each function it appears in

I made a mistake during rebase. Will fix.

That callback is removed in patch 5/13. uarg must remain until then.
