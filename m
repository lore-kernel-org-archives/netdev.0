From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 14:13:25 -0800 (PST)
Message-ID: <20100311.141325.205780761.davem@davemloft.net>
References: <20100311121239.14944fd5@nehalam>
	<20100311.122639.258785986.davem@davemloft.net>
	<20100311140406.37ee0b83@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758513Ab0CKWNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:13:05 -0500
In-Reply-To: <20100311140406.37ee0b83@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 11 Mar 2010 14:04:06 -0800

> That make sense, but maybe we shouldn't send IFLA_STATS64 on
> 32bit platforms.

Let's at least be optimistic that we'll be able to support 64-bit
stats on 32-bit at some point :-)
