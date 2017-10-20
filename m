From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net] packet: avoid panic in packet_getsockopt()
Date: Fri, 20 Oct 2017 12:25:24 -0700
Message-ID: <CANn89iKWZ7qrgaWFJbiRRBcx9mCPdpUjhUKitv_VXK5p_yQOjA@mail.gmail.com>
References: <1508368492.31614.153.camel@edumazet-glaptop3.roam.corp.google.com>
 <201710210201.6l3IUwxu%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, kbuild-all@01.org,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        John Sperbeck <jsperbeck@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:56518 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdJTTZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 15:25:26 -0400
Received: by mail-yw0-f180.google.com with SMTP id l32so7269143ywh.13
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 12:25:26 -0700 (PDT)
In-Reply-To: <201710210201.6l3IUwxu%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 12:11 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Eric,
>
> [auto build test WARNING on net/master]
>
> url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/packet-avoid-panic-in-packet_getsockopt/20171021-003615
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__
>
>
> sparse warnings: (new ones prefixed by >>)
>

Thanks, this was mentioned in the commit changelog.

We will add rcu annotations in net-next.
