From: David Miller <davem@davemloft.net>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Thu, 06 Jan 2011 08:44:33 -0800 (PST)
Message-ID: <20110106.084433.193708782.davem@davemloft.net>
References: <219643.83181.qm@web37604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oakad@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751811Ab1AFQoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 11:44:04 -0500
In-Reply-To: <219643.83181.qm@web37604.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Dubov <oakad@yahoo.com>
Date: Wed, 5 Jan 2011 22:55:43 -0800 (PST)

> On embedded platforms, where real time clock is initialized lately or
> absent outright, this causes TSval field of outgoing TCP packets to be
> set to some garbage value, in my case in the vicinity of 0xffffffff.

The TCP timestamp is set from "jiffies", not from the RTC clock.
