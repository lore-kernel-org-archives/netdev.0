From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] ipv6: Enable netlink notification for tentative
 addresses.
Date: Thu, 26 Aug 2010 13:18:01 -0700 (PDT)
Message-ID: <20100826.131801.246519955.davem@davemloft.net>
References: <20100825.212456.71107442.davem@davemloft.net>
	<4C76B770.4030800@candelatech.com>
	<4C76C73F.4080206@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56893
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753902Ab0HZURq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 16:17:46 -0400
In-Reply-To: <4C76C73F.4080206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 26 Aug 2010 15:57:51 -0400

> But then we get a message for an address that can't be used because
> it hasn't passed DAD, I'm not so sure that is a good thing,
> especially if we don't get notified when it passes DAD.

I think that we shouldn't send notifications for an address that can't
even be used.  So essentially I argue against this patch in any form :)

