From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 07/14] tcp: export data delivery rate
Date: Fri, 16 Sep 2016 16:03:56 -0400
Message-ID: <CADVnQymVmhX86St6aeTh7asW68cC8d3qOZEBrV-ajp1okbx6Zw@mail.gmail.com>
References: <1474051743-13311-8-git-send-email-ncardwell@google.com> <201609171104.7NaqQo41%fengguang.wu@intel.com>
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
Received: from mail-oi0-f41.google.com ([209.85.218.41]:32887 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935021AbcIPUFD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 16:05:03 -0400
Received: by mail-oi0-f41.google.com with SMTP id r126so124750244oib.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 13:04:27 -0700 (PDT)
In-Reply-To: <201609171104.7NaqQo41%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 11:56 PM, kbuild test robot <lkp@intel.com> wrote:
>
>>> net/ipv4/tcp.c:2794:3: note: in expansion of macro 'do_div'
>       do_div(rate, intv);
>       ^~~~~~
>    In file included from arch/arm/include/asm/div64.h:126:0,
>                     from include/linux/kernel.h:142,
>                     from include/linux/crypto.h:21,
>                     from include/crypto/hash.h:16,
>                     from net/ipv4/tcp.c:250:
>>> include/asm-generic/div64.h:224:22: error: passing argument 1 of '__div64_32' from incompatible pointer type [-Werror=incompatible-pointer-types]
>       __rem = __div64_32(&(n), __base); \
...
> > 2794                  do_div(rate, intv);

Looks like 'rate' should be 'rate64'. I will include this fix in the
next version of the patch series.

neal
