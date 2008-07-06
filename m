From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 06 Jul 2008 15:53:18 -0700 (PDT)
Message-ID: <20080706.155318.46569612.davem@davemloft.net>
References: <20080706130801.6bc36cf7@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45855
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754413AbYGFWxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:53:18 -0400
In-Reply-To: <20080706130801.6bc36cf7@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 6 Jul 2008 13:08:01 -0700

> Does this patch look like the right approach for achieving the goal?

It's almost there.

You can issue an ethtool_ops->get_drvinfo() call, on devices which
support ethtool, and fetch the driver info from there.

Your current method of obtaining this info can be used as the
fallback when the ethtool op fails.
