From: davidsen@tmr.com (bill davidsen)
Subject: Re: patricia tries vs. hash for routing?
Date: 28 Oct 2003 13:29:54 GMT
Sender: netdev-bounce@oss.sgi.com
Message-ID: <bnlr0i$prj$1@gatekeeper.tmr.com>
References: <20030919214837.GA3012@sirius.cs.pdx.edu> <20030919233730.75969de6.davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030919233730.75969de6.davem@redhat.com>,
David S. Miller <davem@redhat.com> wrote:
| On Fri, 19 Sep 2003 14:48:37 -0700
| Kristen Carlson <kristenc@cs.pdx.edu> wrote:
| 
| > I was looking through some very old mail list discussions (1996!) on this 
| > topic, and the feeling then was that the code was optimal for < 60,000 routes.
| > Given that much has happened since then, is it still a fair assumption to say
| > that the linux routing algorithm is optimized for < 60,000 routes, but a
| > more BSD-like algorithm works better for > 60,000 routes?
| 
| That's not true at all, the current code can handle many more than
| 60,000 routes.

I don't think "optimized for" meant it wouldn't handle more, just that
performance would degrade.
-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.
