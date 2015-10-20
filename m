From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 20 Oct 2015 04:24:19 -0700 (PDT)
Message-ID: <20151020.042419.299487241092379193.davem@davemloft.net>
References: <562594E1.8040403@oracle.com>
	<1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<56261092.7080003@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbbJTLH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 07:07:58 -0400
In-Reply-To: <56261092.7080003@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Tue, 20 Oct 2015 10:59:46 +0100

> The bug goes into quite some detail about how Solaris behaves. The
> issue here is that we have two implementations, Linux and Solaris,
> both claiming to be POSIX-conformant but both showing different
> behaviour. There's a discussion to be had about the whys and
> wherefores of that difference, but saying that you don't want to know
> how Solaris behaves isn't really going to help move the conversation
> along.

With two decades of precendence, applications will need to find a way
to cope with the behavior on every existing Linux kernel out there.

Even if we were to propose something here and change things, it won't
be available on real sites for 6 months at a minimum, and only a an
extremely small fraction of actual machines.

It's more practical for userspace to cope with the bahvior.  This is
simply because coping with current behavior will work on every Linux
kernel on the planet, and also it won't require us to potentially
break any existing setups.

This to me matters more than any squabbling over semantics or who
really implements POSIX correctly or not.  That simply does not matter
at all.

It especially does not matter as far as I and millions of existing
socket apps out there are concerned.
