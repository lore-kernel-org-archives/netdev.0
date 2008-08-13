From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 patch 0/1] netns: fix kernel panic when receiving a
 multicast packet
Date: Wed, 13 Aug 2008 16:16:43 -0700 (PDT)
Message-ID: <20080813.161643.120250621.davem@davemloft.net>
References: <20080813230409.160213282@mai-009101017029.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50243
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754310AbYHMXQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 19:16:41 -0400
In-Reply-To: <20080813230409.160213282@mai-009101017029.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 14 Aug 2008 01:04:09 +0200

> The following patch makes the multicast support per namespace. It provides
> more a feature than a fix, but can it be considered to be in included for
> the net-2.6 ? I know it is unusual to do that, but I am not sure fixing this bug
> is more safe than just making igmp per namespace.

Agreed.

I combined your description here with the commit log message you
provided for the actual patch.  Please do this in the future,
as it provides the justification for what might seem on the
surface as a feature addition.
