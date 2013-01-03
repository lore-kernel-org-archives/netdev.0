From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: split tcp_ecn sysctl knob to distinguish
 between IPv4 and IPv6
Date: Thu, 03 Jan 2013 04:53:50 -0800 (PST)
Message-ID: <20130103.045350.1322196416782379673.davem@davemloft.net>
References: <20130103000009.GG4464@order.stressinduktion.org>
	<20130103122844.GH4464@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab3ACMxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 07:53:52 -0500
In-Reply-To: <20130103122844.GH4464@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 3 Jan 2013 13:28:44 +0100

> On Thu, Jan 03, 2013 at 01:00:09AM +0100, Hannes Frederic Sowa wrote:
>> ECN could be more reliable when used with IPv6 (I don't have proofs). For
>> people who want to try ECN with IPv6 but still have problems connecting
>> to destinations because of broken IPv4 routers this switch allows one
>> to enable ECN just for IPv6.
>> 
>> Perhaps ECN could be enabled by default in future.
>> 
>> No code changes since initial submission, just added documentation.
> 
> May I ask what lead to the rejection of the patch?

I don't see any value in splitting up ipv4 and ipv6.

I think we should turn the existing knob on unliaterally
by default.  That would be a much better patch.
