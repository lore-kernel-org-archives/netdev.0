From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 07:38:09 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280338.HAA02810@sex.inr.ac.ru>
References: <20020927.195507.87349906.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020927.195507.87349906.davem@redhat.com> from "David S. Miller" at Sep 27, 2 07:55:07 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> suggest applies both to current code and code after Yoshi's change.

This is wrong, unfortunately. The elimination of ipv6_get_saddr()
was trivial before this patch (because of independance of preferred source
on real destination, only on scope), the corresponding fix was withdrawn
from 2.4 only for sake of this feature, pending as a well-known patch.
Now I see retransmission of practicllay the same patch, which was deferred
for improvement that time.

Citing myself two years younger:

> The first priority task is to eliminate address selection function.
> 
> Without this odd feature it was easy and, in fact, address selection
> patches forced me to withdraw the solution from kernel, because
> it makes these hacks much more difficult.

Alexey
