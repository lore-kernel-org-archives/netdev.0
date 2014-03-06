From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_release_cb() should release socket ownership
Date: Wed, 05 Mar 2014 21:15:30 -0500 (EST)
Message-ID: <20140305.211530.2206817902037251680.davem@davemloft.net>
References: <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140305.205938.287751582220842351.davem@davemloft.net>
	<1394071601.27473.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbaCFCPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 21:15:31 -0500
In-Reply-To: <1394071601.27473.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Mar 2014 18:06:41 -0800

> On Wed, 2014-03-05 at 20:59 -0500, David Miller wrote:
> 
>> It really means that sk_lock.owned cannot ever be accessed without the
>> sk_lock spinlock held.
>> 
>> Most of this is easy to hand audit, except sock_owned_by_user() which
>> has call sites everywhere.
>> 
>> Consider adding a locking assertion to it.
> 
> We can do that, but would it be a stable candidate ?
> 
> What about I send a followup for net-next ?

Targetting net-next for the assertion is fine.

Did you get test results back yet?
