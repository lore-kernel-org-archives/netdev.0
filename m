From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats in	action	policer
Date: Mon, 20 Dec 2004 15:03:25 +0100
Message-ID: <20041220140325.GW17998@postel.suug.ch>
References: <20041215130128.GK8493@postel.suug.ch> <1103119774.1077.74.camel@jzny.localdomain> <41C05B60.6030504@trash.net> <1103484249.1046.143.camel@jzny.localdomain> <41C6A6CC.1050105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41C6A6CC.1050105@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41C6A6CC.1050105@trash.net> 2004-12-20 11:17
> I agree that this problem would have been avoided if the
> regression tests were run when the change was made, and it
> made sense to run them at that time. Unfortunately I missed
> the patch when it went in, otherwise I would have objected
> to using a field called "priv" and making assumptions about
> the layout of the structure it points to in a file called
> act_api anyway.

Ifs and buts, it was solely and purely my fault. period.

> On a side-note, you both seem to be inventing your own testing
> framework and regression tests. tcng already includes lots of
> regression tests for tc, tcng and the kernel. Unfortunately,
> last time I checked, it didn't work with 2.6.

The tests are based on tcsim which might behave differently than
the kernel itself. My test framework primarly tries to cover
iproute - kernel incompatbilities and tries to trigger bugs
by running every bit of code in every possible combination.

> I don't feel like I'm distributing burden onto anyone. As I
> said, I run the tests I deem necessary, and I never send out
> patches of whichs correctness I'm not convinced. So far, my
> history of mistakes has been pretty good.

Agreed, the only bug which would have been easly found with the
testframework was the CBQ slab corruption bug due deleting
filters twice added with your generic filter deletion simplification.
Unfortunately, I'm more error-prone than most so I need a testframework.
