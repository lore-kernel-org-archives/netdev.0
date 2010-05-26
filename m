From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] fixes to arp_notify for virtual machine migration
 use case
Date: Tue, 25 May 2010 23:08:22 -0700 (PDT)
Message-ID: <20100525.230822.71096271.davem@davemloft.net>
References: <1273671554.7572.11190.camel@zakaz.uk.xensource.com>
	<20100523.233722.232536798.davem@davemloft.net>
	<1274779201.24218.7164.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	Jeremy.Fitzhardinge@citrix.com, stable@kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41687
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932785Ab0EZGIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 02:08:12 -0400
In-Reply-To: <1274779201.24218.7164.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 25 May 2010 10:20:01 +0100

> Anyway, assuming the fact that arp_notify is disabled by default hasn't
> changed your mind, would adding NETDEV_NOTIFY_PEERS triggered by
> netif_notify_peers() be appropriate or would it be preferable to simply
> add netif_notify_peers() which generates the existing NETDEV_CHANGEADDR?

A seperate NETDEV_NOTIFY_PEERS seems the best idea to me.

> I don't think there's any need for a new sysctl so I'll gate the new
> option on the existing arp_notify one.

Yep, sounds good.
