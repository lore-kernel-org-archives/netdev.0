From: David Miller <davem@davemloft.net>
Subject: Re: includes build break - was Re: [net-next-2.6 PATCH v5 0/3]
 Introduce n-tuple ethtool support
Date: Sun, 14 Feb 2010 22:38:30 -0800 (PST)
Message-ID: <20100214.223830.161700350.davem@davemloft.net>
References: <20100211020310.23436.85885.stgit@localhost.localdomain>
	<20100210.195445.190157100.davem@davemloft.net>
	<4B77E4EC.30407@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34686
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753404Ab0BOGiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 01:38:15 -0500
In-Reply-To: <4B77E4EC.30407@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sun, 14 Feb 2010 12:56:28 +0100

> The patch below fixes the issue.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Oliver, thanks for your patch.

I'm going to fix this slightly differently by moving
the rculist.h include down into the existing __KERNEL__
ifdef protected code block.

Thanks!
