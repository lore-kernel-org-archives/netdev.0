From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 13:12:26 -0800
Message-ID: <1356815546.21409.5277.camel@edumazet-glaptop>
References: <20121229092417.GA4038@paralelels.com>
	 <1356789203.21409.3923.camel@edumazet-glaptop>
	 <20121229145030.GA7959@paralelels.com>
	 <1356802828.21409.4623.camel@edumazet-glaptop>
	 <1356807516.4102.4.camel@edumazet-laptop>
	 <1356810062.21409.4991.camel@edumazet-glaptop>
	 <20121229200848.GA3389@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vvs@parallels.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:32772 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab2L2VM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 16:12:29 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so5239930dam.18
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 13:12:28 -0800 (PST)
In-Reply-To: <20121229200848.GA3389@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-30 at 00:08 +0400, Andrew Vagin wrote:

> Is it right, that a received window will be less, if packets are not sorted?
> Looks like a bug.

Not really a bug.

TCP is very sensitive to packet reorders. I wont elaborate here as
its a bit off topic.

Try to reorders credits/debits on your bank account, I am pretty sure
you'll lose some money or even get serious troubles.

Of course, enabling GRO on eth0 would definitely help a bit...

(once/iff veth driver features are fixed to allow GSO packets being
forwarded without being segmented again)
