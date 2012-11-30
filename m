From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: verify length provided in heartbeat information
 parameter
Date: Fri, 30 Nov 2012 12:26:34 -0500 (EST)
Message-ID: <20121130.122634.395602436506279741.davem@davemloft.net>
References: <20121130121627.GG30697@casper.infradead.org>
	<20121130160156.GC6039@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab2K3R0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:26:37 -0500
In-Reply-To: <20121130160156.GC6039@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 30 Nov 2012 11:01:57 -0500

> On Fri, Nov 30, 2012 at 12:16:27PM +0000, Thomas Graf wrote:
>> If the variable parameter length provided in the mandatory
>> heartbeat information parameter exceeds the calculated payload
>> length the packet has been corrupted. Reply with a parameter
>> length protocol violation message.
>> 
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
...
>> 
> Looks good, thanks Thomas.
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 

Applied, thanks.
