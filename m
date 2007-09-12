From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.24][NETNS][patch 2/3] fix loopback network namespace
 initialization
Date: Wed, 12 Sep 2007 05:55:03 -0700 (PDT)
Message-ID: <20070912.055503.70206923.davem@davemloft.net>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
	<20070912124419.150545693@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:36391
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S966602AbXILMz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:55:28 -0400
In-Reply-To: <20070912124419.150545693@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: dlezcano@fr.ibm.com
Date: Wed, 12 Sep 2007 14:38:13 +0200

> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> 
> The core patchset of the network namespace sent by 
> Eric Biederman does not do dynamic loopback creation.
> So there is no call to alloc_netdev_mq which fills the
> network namespace field of the netdevice.
> 
> This patch assign the loopback to the init network namespace.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks.
