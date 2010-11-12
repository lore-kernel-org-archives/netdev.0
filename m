From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix message size calculation for link
 messages
Date: Fri, 12 Nov 2010 10:53:18 -0800 (PST)
Message-ID: <20101112.105318.226783106.davem@davemloft.net>
References: <20101112014759.GA8491@canuck.infradead.org>
	<4CDCF032.7040802@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49344
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751405Ab0KLSwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 13:52:54 -0500
In-Reply-To: <4CDCF032.7040802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 12 Nov 2010 08:43:46 +0100

> On 12.11.2010 02:47, Thomas Graf wrote:
>> nlmsg_total_size() calculates the length of a netlink message
>> including header and alignment. nla_total_size() calculates the
>> space an individual attribute consumes which was meant to be used
>> in this context.
>> 
>> Also, ensure to account for the attribute header for the
>> IFLA_INFO_XSTATS attribute as implementations of get_xstats_size()
>> seem to assume that we do so.
>> 
>> The addition of two message headers minus the missing attribute
>> header resulted in a calculated message size that was larger than
>> required. Therefore we never risked running out of skb tailroom.
>> 
>> Signed-off-by: Thomas Graf <tgraf@infradead.org>
>> Cc: Patrick McHardy <kaber@trash.net>
> 
> Looks good to me, thanks Thomas.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
