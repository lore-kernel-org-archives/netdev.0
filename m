From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/6] ipv4: Delete routing cache.
Date: Wed, 25 Jul 2012 11:02:50 -0700
Message-ID: <501034CA.8050109@candelatech.com>
References: <20120712.104253.1298961759089179385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49870 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab2GYSCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 14:02:52 -0400
In-Reply-To: <20120712.104253.1298961759089179385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just ran a quick test on yesterday's net-next, and our
virtual-router logic appears to work fine.

This logic sets up lots of routing rules and routing tables
and basically routes the same packet through multiple
VETH links.

We'll do some more extensive testing, including performance related stuff
when we move to newer upstream kernels with this feature.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
