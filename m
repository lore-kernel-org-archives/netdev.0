From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] anycast support for IPv6, updated to 2.5.44
Date: Thu, 20 Mar 2003 00:34:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF4D6C9027.2F431095-ON88256CEF.002804BF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: yoshfuji@wide.ad.jp, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Yoshifuji,
      I created the multicast-like API because, aside from the in-kernel
use, there was no way to use anycasting otherwise, and I believe for at
least the high-availability case, it doesn't make any sense to treat it
like a unicast address. An exited DNS server program with the server
machine still up will in fact deny service to clients that might otherwise
find a working server if the "permanent" address model were not there. With
a multicast-like interface at least available, programs have the choice of
tying the anycast address to whether or not the service that needs it is
running.
      That said, there's no reason why you can't have both, and that's
straightforward with the code (but not implemented). I think it's too early
to be concerned with compatibility since there is no alternative
non-permanent anycast address API. If Linux has an API to do something that
can't be done at all on other systems, there clearly isn't a portability
issue.

                        +-DLS
