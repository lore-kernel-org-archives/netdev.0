From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Tue, 07 May 2013 14:58:15 -0700 (PDT)
Message-ID: <20130507.145815.205664097646870885.davem@davemloft.net>
References: <CAAsGZS7TVr2YX8H8EQRqk4gDwNMQiaOkjhwCuLM_27RqB6+QgQ@mail.gmail.com>
	<518968DF.9070008@redhat.com>
	<1367963787.13473.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, loke.chetan@gmail.com, netdev@vger.kernel.org,
	darkjames-ws@darkjames.pl
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab3EGV6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 17:58:21 -0400
In-Reply-To: <1367963787.13473.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 May 2013 14:56:27 -0700

> On Tue, 2013-05-07 at 22:49 +0200, Daniel Borkmann wrote:
> 
>> Right, and now we treat people who write crappy applications with BUG?
>> 
>> BUG is only for consistency checks *within* the kernel and not meant to
>> be triggered on purpose from user space.
> 
> +1

+1
