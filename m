From: jflf-kernel@gmx.com
Subject: Re: [PATCH] r8152: add missing Makefile rule
Date: Sun, 03 Aug 2014 09:52:58 +0200
Message-ID: <53DDEA5A.4010008@gmx.com>
References: <53DC2230.9010504@gmx.com> <20140802.204134.360329908595614221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:59276 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbaHCHxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2014 03:53:06 -0400
In-Reply-To: <20140802.204134.360329908595614221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/08/14 05:41 AM, David Miller wrote:
> From: jflf-kernel@gmx.com
> Date: Sat, 02 Aug 2014 01:26:40 +0200
> 
>>  Is seems that this issue has existed ever since the driver was
>>  added back in 3.10. In Linus' git tree the drivers/net/Makefile was
>>  last modified before the inclusion of the driver, so I don't know
>>  if it's ever been possible to build it.
> 
> It gets built, as long as at least one other USB networking driver has
> been selected.
> 
> Most people (distributions, developers, maintainers) select all
> drivers or some large subset thereof, so would never actually run into
> this problem.
> 
> You'd have to specifically have a configuration that enabled r8152 and
> no other USB networking driver, in order to trigger this.
> 
> Anyways, I'll apply this, thanks.

Very true, thank you for pointing it out. If you haven't done so yet,
the patch description could be changed to something like:

When it is the only USB net driver selected, the r8152 driver doesn't
get built because of a missing rule in drivers/net/Makefile. This change
adds the rule and lets the driver build.

Thank you!
JF
