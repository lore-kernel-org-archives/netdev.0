From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [RFC 0/2] Account for duplicate ACKs with invalid SACK-blocks
Date: Wed, 21 Aug 2013 21:15:31 -0700
Message-ID: <52159063.5010000@fatooh.org>
References: <1376935800.4226.71.camel@edumazet-glaptop> <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be> <20130821.203201.369023440348094508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, kernel@linuxace.com,
	benjamin.hesmans@uclouvain.be
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:53500 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031Ab3HVEPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 00:15:33 -0400
In-Reply-To: <20130821.203201.369023440348094508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-08-21 20:32, David Miller wrote:
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Mon, 19 Aug 2013 21:29:26 +0200
> 
>> There exist sequence-number rewriting middleboxes, who do not modify the 
>> sequence-number in the SACK-blocks.
> 
> These are bugs that the vendor's should fix, not something we should
> cater to at all.
> 
> I'm not applying patches like these, and I've rejected similar
> workarounds in the past 18 years, so this position is strong and
> consistent.
> 
> Sorry.

That's not terrible for me; we'll most likely be turning off SEQ
randomization on the FWSM, when we have time to make sure it doesn't
break anything (which it shouldn't).

-Corey
