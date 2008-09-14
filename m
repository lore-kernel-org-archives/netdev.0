From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Sat, 13 Sep 2008 22:11:32 -0400
Message-ID: <48CC72D4.1020001@garzik.org>
References: <47CD4857.2060406@student.tuwien.ac.at> <20080321202202.129c1239@ors>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hvr@gnu.org, buytenh@wantstofly.org
To: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36699 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbYINCLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 22:11:36 -0400
In-Reply-To: <20080321202202.129c1239@ors>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Martin wrote:
> Am Tue, 04 Mar 2008 14:02:15 +0100
> schrieb Oliver Martin <oliver.martin@student.tuwien.ac.at>:
>> Now I'm having different problems: When auto-negotiation is enabled,
>> it sometimes randomly changes the link state:
>>
>> PHY: 0:01 - Link is Down
>> PHY: 0:01 - Link is Up - 100/Full
>>
> 
> I've found at least one part of the problem. The MDIO clock divisor
> wasn't set again after the reset in ep93xx_start_hw. It was left at the
> default, resulting in a 12.5 MHz clock, which the PHY (Micrel KSZ8721BL)
> didn't like too much. Calling ep93xx_mdio_reset after the reset fixed
> it, the link is now perfectly stable in auto-negotiation mode.
> 
> There still seems to be another bug with auto-negotiation disabled: It
> doesn't switch to 1000 Mbps any more, but most times it doesn't stay in
> the intended configuration either. I haven't done any extensive
> testing of this yet, though.
> 
> Signed-off-by: Oliver Martin <oliver.martin@student.tuwien.ac.at>

Testing feedback?  Lennert ack?


