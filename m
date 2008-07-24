From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/3] net: per skb control messages
Date: Thu, 24 Jul 2008 13:28:21 -0700 (PDT)
Message-ID: <20080724.132821.212118602.davem@davemloft.net>
References: <200807241634.31614.opurdila@ixiacom.com>
	<20080724150116.GA8692@gondor.apana.org.au>
	<200807241922.57361.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751623AbYGXU2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 16:28:21 -0400
In-Reply-To: <200807241922.57361.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Thu, 24 Jul 2008 19:22:57 +0300

> Would that be acceptable (with proper CONFIG_HW_TSTAMPS of course)?

Adding new fields to struct sk_buff that take up space is generally
not allowed unless the new field adds substantially to the benefit of
a large group of users of Linus.

I don't think that applied here for this hw-tstamps stuff.

And yes, this is even with the config option protection, because every
distribution is going to turn all the options on, which makes them
essentially pointless from a sk_buff overhead perspective.
