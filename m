From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] IPv6 NAT: Do not drop DNATed 6to4/6rd packets
Date: Sat, 28 Sep 2013 15:57:50 -0400 (EDT)
Message-ID: <20130928.155750.1130089685321379918.davem@davemloft.net>
References: <1379963485.3575.53.camel@joe-AO722>
	<1379966659-28838-1-git-send-email-catab@embedromix.ro>
	<20130924213606.GB4446@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catab@embedromix.ro, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, joe@perches.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab3I1T5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 15:57:53 -0400
In-Reply-To: <20130924213606.GB4446@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 24 Sep 2013 23:36:06 +0200

> On Mon, Sep 23, 2013 at 11:04:19PM +0300, Catalin(ux) M. BOIE wrote:
>> When a router is doing  DNAT for 6to4/6rd packets the latest anti-spoofing
>> patch (218774dc) will drop them because the IPv6 address embedded
>> does not match the IPv4 destination. This patch will allow them to
>> pass by testing if we have an address that matches on 6to4/6rd interface.
>> I have been hit by this problem using Fedora and IPV6TO4_IPV4ADDR.
>> Also, log the dropped packets (with rate limit).
>> 
>> Signed-off-by: Catalin(ux) M. BOIE <catab@embedromix.ro>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, but Catalin please strictly refer to changes in the following
precise format:

	commit $SHA1_ID ("Commit message header line text")

Because SHA1_IDs are ambiguous, especially when the change in question
is backported into various -stable branches.

The only way to resolve the ambiguity is to provide the commit message
text (in parenthesis and double quotes).
