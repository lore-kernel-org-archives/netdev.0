From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 08 Jul 2008 14:31:58 -0700 (PDT)
Message-ID: <20080708.143158.182627862.davem@davemloft.net>
References: <20080707.155723.48071035.davem@davemloft.net>
	<adazlotwalk.fsf@cisco.com>
	<4873BC67.8010205@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, shemminger@vyatta.com, arjan@infradead.org,
	netdev@vger.kernel.org
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbYGHVb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 17:31:58 -0400
In-Reply-To: <4873BC67.8010205@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Tue, 08 Jul 2008 14:13:43 -0500

> So should I put the rtnl acquisitions back in iw_cxgb3?  Or fix cxgb3 to 
> not assume rtnl is held?

It appears that the kernel always invokes the ethtool ops with
RTNL held, and therefore that's the environment that needs
to be ensured.
