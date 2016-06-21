From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Tue, 21 Jun 2016 04:29:18 -0400 (EDT)
Message-ID: <20160621.042918.1782717212289281861.davem@davemloft.net>
References: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
	<20160619.200741.1114304127682357737.davem@davemloft.net>
	<CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbcFUI3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 04:29:42 -0400
In-Reply-To: <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 20 Jun 2016 08:13:48 -0700

> Routing around the problem is already being done.

QUIC, a new protocol used for specific purposes and implemented in
userspace from the start is significantly different from making the
kernel's _TCP_ implementation bypassed into a userspace one just by
UDP encapsulating it.

That is a major and conscious change in our mentality.

The consequences are far and wide, and I'm having a very hard time
seeing the benefits you cite being larger than the negatives here.
