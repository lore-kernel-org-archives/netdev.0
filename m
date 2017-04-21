From: David Miller <davem@davemloft.net>
Subject: Re: net/core: BUG in unregister_netdevice_many
Date: Fri, 21 Apr 2017 15:38:40 -0400 (EDT)
Message-ID: <20170421.153840.2181333362371190008.davem@davemloft.net>
References: <CAAeHK+zUZMGQuW=7Qhz3EWYjh6Zwv9eMBCiMCU79QrYNWox0-Q@mail.gmail.com>
        <CA+55aFwg=OtMWmU153uM27Fwk5eVv5ZBGBA9phQqVqn3nNAy6Q@mail.gmail.com>
        <CAM_iQpUoWzeZPSKTCm13tumvOa7fLMJnz_0F_LSq4odYvWtRaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, andreyknvl@google.com,
        edumazet@google.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexander.h.duyck@intel.com,
        dsa@cumulusnetworks.com, daniel@iogearbox.net, me@tobin.cc,
        jiri@mellanox.com, stephen@networkplumber.org, dvyukov@google.com,
        kcc@google.com, syzkaller@googlegroups.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425274AbdDUTin (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:38:43 -0400
In-Reply-To: <CAM_iQpUoWzeZPSKTCm13tumvOa7fLMJnz_0F_LSq4odYvWtRaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 21 Apr 2017 11:55:04 -0700

> On Fri, Apr 21, 2017 at 10:25 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>> On Fri, Apr 21, 2017 at 5:48 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>>>
>>> I've got the following error report while fuzzing the kernel with syzkaller.
>>>
>>> ------------[ cut here ]------------
>>> kernel BUG at net/core/dev.c:6813!
>>
>> Another useless BUG_ON() that
> 
> I think we are double-unregister'ing the pim6reg device,
> we probably need something like:

This particular bug is fixed by Nikolay's fix.

I'm not saying you haven't spotted another bug.
