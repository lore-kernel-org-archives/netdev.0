From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 23:49:13 -0400 (EDT)
Message-ID: <20141030.234913.314319804895249709.davem@davemloft.net>
References: <1414710342.15352.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141030231637.GF10069@breakpoint.cc>
	<1414711801.499.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaJaDtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 23:49:16 -0400
In-Reply-To: <1414711801.499.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Oct 2014 16:30:01 -0700

> On Fri, 2014-10-31 at 00:16 +0100, Florian Westphal wrote:
> 
>> I see. So that makes ecn=1 default a pure fantasy.
> 
> Well, I had this dream about 2 or 3 years ago, but I eventually came to
> this (sad) conclusion.

We really should have done this from the beginning, but I guess we
lacked the courage to do so.

Some security nuts will say that the ECN bits are some covert channel
of communication and block connections based upon that, instead of,
you know, just clearing the bits.

Ok ok, Florian please resubmit your original patches.  We'll go with a
boolean per-route override.  Thanks for taking the time to discuss
this with us.
