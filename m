From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Deconstruct struct fib_result
Date: Fri, 27 Jul 2012 23:55:49 -0700 (PDT)
Message-ID: <20120727.235549.2244701016209116514.davem@davemloft.net>
References: <20120727.211814.1628871775065221675.davem@davemloft.net>
	<CAKgT0UcuvFGJTCxMwVa+rEnQHaNg0V6EH4XpO29fXuFADSBpAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078Ab2G1Gzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 02:55:52 -0400
In-Reply-To: <CAKgT0UcuvFGJTCxMwVa+rEnQHaNg0V6EH4XpO29fXuFADSBpAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 27 Jul 2012 23:41:50 -0700

> I was wondering why you couldn't wrap the tclassid value in result
> with an #ifdef CONFIG_IP_ROUTE_CLASSID so that it is stripped if you
> don't have that defined?

I am so over these feature ifdefs in the routing code, because
realistically everyone turns all the crap on.  Therefore we have to be
optimal when it's all on.
