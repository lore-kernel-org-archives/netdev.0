From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET/PHY: Eliminate the forced speed reduction algorithm
Date: Mon, 25 Feb 2013 15:59:12 -0500 (EST)
Message-ID: <20130225.155912.1003926244088919460.davem@davemloft.net>
References: <1361795118.3980.108.camel@kkk.nita.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kapranoff@inbox.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361795118.3980.108.camel@kkk.nita.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Kapranov <kapranoff@inbox.ru>
Date: Mon, 25 Feb 2013 16:25:18 +0400


To be completely honest with you, I'm really getting tired of
making corrections to this one simple patch submission.

> From Kirill Kapranov  <kkk@nita.ru>,<kapranoff@inbox.ru>

It makes no sense to mention multiple email addresses in your
authorship line, reduce it to one.

If you cannot do things like this correctly on your own, have
automated tools (such as git) generate these patch emails for you.

> NET/PHY: Eliminate the forced speed reduction algorithm.

You do not need to mention the commit header line again, all
this does is make more work for me as I have to edit it out.
To one in the Subject line is sufficient, and you should not
use all-CAPS, and also the subsystem indication is not correct.
Your subject line should be something like:

"[PATCH] phy: Eliminate the forced speed reduction algorithm"

That is, remove the "NET/" part, leave "PHY" and make it all
lowercase.

> In case of fixed speed set up for a NIC (e.g. ethtool -s eth0 autoneg off speed 100 duplex full) with an ethernet cable plugged off, the mentioned algorithm slows down a NIC speed, so further hooking up a cable does not lead to "link" state.

I also had to formate this paragraph down to 80 column lines instead
of one long one.

> Signed-off-by: Kirill Kapranov <kkk@nita.ru>,<kapranoff@inbox.ru>

Again, using two email address is not correct, just use one.

Please, do yourself a huge favor, look at how other people submit
accepted patches on this list.  Learn by example rather than making
many mistakes trying to figure things out purely on your own.

> I have looked up RFC-802.3, and found, that the mentioned algorithm is neither quoted nor described. AFAIK, no one RFC describe the mentioned algorithm, so it may be a witty invention of the developer(s).

At the time that autonegiation was a new or non-existing feature, this
approach of stepping down the link parameters trying different
settings one-by-one was an absolute necessity.  It's probably not
needed anymore in modern times.

> Tested at 2.6.38.7, applicable up to for 3.0.4. 

This patch does not apply to current upstream sources at all.
