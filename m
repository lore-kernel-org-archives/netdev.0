From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: implement 64 bit stats
Date: Sat, 01 Jan 2011 14:02:35 -0800 (PST)
Message-ID: <20110101.140235.71111544.davem@davemloft.net>
References: <20101231173427.17f07ad3@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752691Ab1AAWCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 17:02:04 -0500
In-Reply-To: <20101231173427.17f07ad3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 31 Dec 2010 17:34:27 -0800

> This implements 64 bit statistics support and fixes races when reading
> counter values. The PHY counters can only be accessed 16 bits at a time,
> so they are subject to carry races.
> 
> NB:
>   * TX/RX counters are maintained in software because the the hardware packet count
>     is only a 32 bit value.
> 
>   * Error counters are really only 32 bit.
> 
>   * Old 32 bit counter fields in dev->stats still used for some
>     software counters
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
