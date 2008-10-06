From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Mon, 06 Oct 2008 16:18:36 -0700
Message-ID: <48EA9CCC.2050505@hp.com>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>	<20081006195446.1dc5a372@speedy>	<48EA9223.8090700@trash.net> <48EA964A.6060503@hp.com> <48EA98F0.40302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:23308 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbYJFXTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 19:19:36 -0400
In-Reply-To: <48EA98F0.40302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Rick Jones wrote:
> 
>> Patrick McHardy wrote:
>>
>>> Agreed. But the question when to do automatic adjustments remains.
>>
>>
>> A matter of interpretation of the principle of least surprise right? 
>> Which is less surprising - that a VLAN's MTU drops to match that of 
>> the physical interface or that some traffic on the VLAN stops when the 
>> physical interface's MTU drops?
> 
> 
> The traffic actually shouldn't stop since the MTU isn't enforced by
> the lower layers and also usually not by the driver. So I feel unable
> to make a policy decision when both views don't seem unreasonable.
> Especially given the fact that the "more suprising" behaviour so far
> has been our default.

Does changing the MTU on a physical interface not change the size frame 
the NIC itself will be willing to accept?

rick jones
