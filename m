From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: schedule while atomic bug during dev_disable_lro
 2.6.31-rc3
Date: Thu, 16 Jul 2009 13:17:29 -0700 (PDT)
Message-ID: <20090716.131729.148777441.davem@davemloft.net>
References: <4A5E5F8A.308@candelatech.com>
	<Pine.WNT.4.64.0907161206260.5316@ppwaskie-MOBL2.amr.corp.intel.com>
	<4A5F8062.6090009@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933261AbZGPURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 16:17:24 -0400
In-Reply-To: <4A5F8062.6090009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 16 Jul 2009 12:32:50 -0700

> I believe the trigger for this is my script that enables ip_forward.
> I'm not twiddling LRO settings directly as far as I can tell.

Turning on/off bridging or forwarding twiddles the LRO settings
as a side effect.
