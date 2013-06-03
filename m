From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/2] ping: some cleanup for net/ipv4/ping.c
Date: Mon, 03 Jun 2013 00:24:04 -0700 (PDT)
Message-ID: <20130603.002404.131723623530817410.davem@davemloft.net>
References: <CAKD1Yr0zHsM85ZJLwCeE6NkEZnaMqs3ba1PyOa_M09UB6i99=g@mail.gmail.com>
	<1370243586.32297.5.camel@cr0>
	<CAKD1Yr2fn51+5JEUN2vg+NJ7yv_Fe-WqPhETFee5mv+_FJDaMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab3FCHYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:24:05 -0400
In-Reply-To: <CAKD1Yr2fn51+5JEUN2vg+NJ7yv_Fe-WqPhETFee5mv+_FJDaMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon, 3 Jun 2013 16:17:25 +0900

> On Mon, Jun 3, 2013 at 4:13 PM, Cong Wang <amwang@redhat.com> wrote:
>> Remember it is a cleanup, not a bug fix, right? :) I don't think there
>> is any way to make this 10- line of code hard to read.
> 
> I suppose, if growing the function from 2 to 9 lines without changing
> its behaviour can be called a "cleanup". :-)

I have to say this patch makes the code look worse, ifdefs are 99
times out of 100 the wrong thing to do.

Sorry I won't be applying these patches.
