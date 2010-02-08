From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC 3/4] bond: support more Layer 4 protocols
Date: Mon, 08 Feb 2010 14:11:37 +0100
Message-ID: <4B700D89.2080303@trash.net>
References: <20100204171118.917737392@vyatta.com>	<20100204171241.393163298@vyatta.com>	<4B6BF50D.9060603@trash.net> <20100205084240.0bd895ab@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33966 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364Ab0BHNLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:11:41 -0500
In-Reply-To: <20100205084240.0bd895ab@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 05 Feb 2010 11:38:05 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Stephen Hemminger wrote:
>>> +/* Map of protocols with standard ports available to include in hash */
>>> +static const bool has_layer4[256] = {
>>> +	[IPPROTO_TCP] = 1,
>>> +	[IPPROTO_UDP] = 1,
>>> +	[IPPROTO_UDPLITE] = 1,
>>> +	[IPPROTO_SCTP] = 1,
>>> +	[IPPROTO_DCCP] = 1,
>>> +	[IPPROTO_ESP] = 1,
>>> +};
>>> +
>> How about using a bitmap or u8s to keep this more compact?
> 
> I thought about that, but couldn't find a clever way to initialize at
> compile time other than hardcoding constants?

Maybe an __init function with a couple of set_bit() calls?
Otherwise I'd suggest to simply use u8.

