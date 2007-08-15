From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Wed, 15 Aug 2007 16:05:57 -0700 (PDT)
Message-ID: <20070815.160557.104645231.davem@davemloft.net>
References: <20070810202426.GA25050@havoc.gtf.org>
	<46BCD0F1.8040006@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756504AbXHOXGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 19:06:00 -0400
In-Reply-To: <46BCD0F1.8040006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 10 Aug 2007 16:56:17 -0400

> All this is currently checked into the 'eflags' branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> 
> But when everybody is happy with it, IMO we should get it into 
> net-2.6.24.git, as it enables LRO.

I've backed out the ETHTOOL LRO stuff from Auke, and applied your
patches to net-2.6.24

We can get rid of that NETIF_F_LRO thing, since as you observed
it is indeed superfluous.

