From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Wed, 22 Jun 2016 15:23:07 -0400 (EDT)
Message-ID: <20160622.152307.631430680793264716.davem@davemloft.net>
References: <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
	<20160621.042918.1782717212289281861.davem@davemloft.net>
	<CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbcFVTXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 15:23:13 -0400
In-Reply-To: <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>
Date: Tue, 21 Jun 2016 20:42:19 -0700

> I don't believe TOU will lead to a proliferation of TCP
> implementations in the userland - getting a solid TCP implementation
> is hard.

The fear isn't doing legitimate things.

It's making TCP stacks that do evil stuff on purpose.

Also, making proprietary TCP stacks that override the kernel one.

And finally, here's the best part, all of the above can be done as a
new, huge, potential attack vector for hackers.

All they need is to get this evil TCP stack working once, then it's
in every root kit out there.  If you can take over the TCP stack of
a several hundred thousand machine strong botnet, imagine what you
could do.

And the TOU facility... facilitates this.
