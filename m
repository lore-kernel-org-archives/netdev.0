From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 15:46:01 -0700 (PDT)
Message-ID: <20070810.154601.98709831.davem@davemloft.net>
References: <46BCD47C.9060408@candelatech.com>
	<20070810.151039.31642625.davem@davemloft.net>
	<46BCE942.1030107@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55905
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753415AbXHJWqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:46:00 -0400
In-Reply-To: <46BCE942.1030107@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 10 Aug 2007 15:40:02 -0700

> For GSO on output, is there a generic fallback for any driver that
> does not specifically implement GSO?

Absolutely, in fact that's mainly what it's there for.

I don't think there is any issue.  The knob is there via
ethtool for people who really want to disable it.
