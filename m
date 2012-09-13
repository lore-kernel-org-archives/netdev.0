From: David Miller <davem@davemloft.net>
Subject: Re: Remarks and comments about ipconfig behavior
Date: Thu, 13 Sep 2012 16:31:34 -0400 (EDT)
Message-ID: <20120913.163134.361379133013906511.davem@davemloft.net>
References: <5052403B.4040408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: erwanaliasr1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519Ab2IMUbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:31:36 -0400
In-Reply-To: <5052403B.4040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erwan Velu <erwanaliasr1@gmail.com>
Date: Thu, 13 Sep 2012 22:21:15 +0200

> That lever for me two points :
> - why is this timeout setup for so long ? Even with a spantree
> - configuration, not having a carrier for 2mn is *waow* ... Does a 30sec
> - could not be enough ? What is the need of waiting so long time ?

I've seen PHY/switch/hub combinations that take longer than 30 seconds
to fully negotiate the link.

There is really no upper limit to the link speed/duplex/etc.
negoatiation process.

Even if the actual negoatiation protocol had an upper limit on
negoatiation time, hardware implementations do things like try
sampling the quality of the cable signal and may choose to
down-rev the advertised features and restart the negoatiation.
