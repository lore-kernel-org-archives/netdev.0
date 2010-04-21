From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 18:16:48 -0700 (PDT)
Message-ID: <20100420.181648.183008607.davem@davemloft.net>
References: <20100420.180253.159346294.davem@davemloft.net>
	<Pine.LNX.4.64.1004202108240.27476@hs20-bc2-1.build.redhat.com>
	<20100420.181434.35828504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754071Ab0DUBQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:16:46 -0400
In-Reply-To: <20100420.181434.35828504.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 20 Apr 2010 18:14:34 -0700 (PDT)

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Tue, 20 Apr 2010 21:10:04 -0400 (EDT)
> 
>> I see, but GRO is turned off on my interfaces, according to ethtool.
> 
> GRO is just a flag bit, so it's possible that if your kernel is too
> old ethtool will always show that it's off.

Actually, looking back at your original report, are you confusing
"large-receive-offload" as reported by ethtool with GRO?

They are completely seperate things.

"large-receive-offload" is LRO, whereas GRO is something done
in software and something entirely different.
