From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet32: round off carrier watch timer
Date: Thu, 08 Jan 2009 11:17:20 -0800 (PST)
Message-ID: <20090108.111720.69522736.davem@davemloft.net>
References: <20090107121036.4e16b7cf@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762289AbZAHTRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:17:18 -0500
In-Reply-To: <20090107121036.4e16b7cf@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 7 Jan 2009 12:10:36 -0800

> The link check watchdog timer on this driver fires every two seconds, but
> since not aligned it causes extra wakeups. It is more important on this
> driver than most because it is the hardware that is emulated by default
> when using network interfaces on VMware.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
