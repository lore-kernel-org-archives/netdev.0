From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Don't reduce hop limit for an interface
Date: Wed, 25 Mar 2015 11:42:08 -0400 (EDT)
Message-ID: <20150325.114208.540509748559553203.davem@davemloft.net>
References: <1427272141.10689.7.camel@takeit.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ljungmark@modio.se, spider@takeit.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbbCYPmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 11:42:09 -0400
In-Reply-To: <1427272141.10689.7.camel@takeit.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "D. S. Ljungmark" <spider@takeit.se>
Date: Wed, 25 Mar 2015 09:29:01 +0100

> From 3ae93eb68a06ab2d9c984c6708dbc9e5f3bc8251 Mon Sep 17 00:00:00 2001
> From: "D.S. Ljungmark" <ljungmark@modio.se>
> Date: Wed, 25 Mar 2015 09:28:15 +0100
> Subject: [PATCH] ipv6: Don't reduce hop limit for an interface
> 
> A local route may have a lower hop_limit set than global routes do.
> 
> RFC 3756, Section 4.2.7, "Parameter Spoofing"
> 
>>   1.  The attacker includes a Current Hop Limit of one or another small
>>       number which the attacker knows will cause legitimate packets to
>>       be dropped before they reach their destination.
> 
>>   As an example, one possible approach to mitigate this threat is to
>>   ignore very small hop limits.  The nodes could implement a
>>   configurable minimum hop limit, and ignore attempts to set it below
>>   said limit.
> 
> Signed-off-by: D.S. Ljungmark <ljungmark@modio.se>

Applied and queued up for -stable.
