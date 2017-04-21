From: David Miller <davem@davemloft.net>
Subject: Re: net/core: BUG in unregister_netdevice_many
Date: Fri, 21 Apr 2017 15:37:02 -0400 (EDT)
Message-ID: <20170421.153702.1599786428994860703.davem@davemloft.net>
References: <CAAeHK+zUZMGQuW=7Qhz3EWYjh6Zwv9eMBCiMCU79QrYNWox0-Q@mail.gmail.com>
        <CA+55aFwg=OtMWmU153uM27Fwk5eVv5ZBGBA9phQqVqn3nNAy6Q@mail.gmail.com>
        <CA+55aFyTFzML+_8E_kDjX=YFkaDi_ejGo15UgGtAT29244UwgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, edumazet@google.com, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.h.duyck@intel.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, me@tobin.cc, jiri@mellanox.com,
        stephen@networkplumber.org, dvyukov@google.com, kcc@google.com,
        syzkaller@googlegroups.com
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyTFzML+_8E_kDjX=YFkaDi_ejGo15UgGtAT29244UwgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Apr 2017 10:42:48 -0700

> Over to Eric and networking people. This oops is user-triggerable, and
> leaves the machine in a bad state (the original BUG_ON() and the new
> GP fault both happen while holding the RTNL, so networking is not
> healthy afterwards.

I have the fix in my tree and will push it to shortly.
