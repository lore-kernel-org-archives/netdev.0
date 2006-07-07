From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Re: SKB BUG: Invalid truesize
Date: Fri, 7 Jul 2006 11:16:45 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C9612500242BA@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:50144 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S932068AbWGGJQS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 05:16:18 -0400
To: "'Auke Kok'" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Does it harm?
>> 
>> SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
>> SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
>> SKB BUG: Invalid truesize (348) len=1383, sizeof(sk_buff)=156
>> SKB BUG: Invalid truesize (316) len=1383, sizeof(sk_buff)=156
>> SKB BUG: Invalid truesize (380) len=1383, sizeof(sk_buff)=156
>> 
>> I found it in the log of a 2.6.17 box using IPSEC tunnels.

> it does harm, we need to know which network driver(s) are/were loaded when

> this happened, for starters.

It happened only once during quick mode of an IPSEC tunnel.
Two 3c905C cards, both with 3c59x, non-module build.
