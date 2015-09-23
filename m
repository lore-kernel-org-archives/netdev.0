From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 11:19:59 -0700 (PDT)
Message-ID: <20150923.111959.295309376360736446.davem@davemloft.net>
References: <5602DDC1.2080403@cumulusnetworks.com>
	<5602E39D.6060509@gmail.com>
	<5602E957.2060409@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbbIWSUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:20:01 -0400
In-Reply-To: <5602E957.2060409@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 23 Sep 2015 12:03:03 -0600

> They add a lot of value. They make each change very easy to follow. No
> one is going to pickup a single patch in this series and backport to
> some kernel. Each is dependent on the one before it. Given that I
> would rather waste a few steps and ensure I arrive at the destination
> without error.

The problem is that people will, in the future, have the backport bug
fixes _THROUGH_ all of these code rearrangements.

And the person who is going to have to do that, is _ME_.

And if that kind of pain is going to be bestowed upon me, it has to
be for something of great value.

I do not see great value in your rearrangements here, not at all.
