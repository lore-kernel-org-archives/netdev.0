From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Mon, 06 Oct 2008 15:50:50 -0700
Message-ID: <48EA964A.6060503@hp.com>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net>	<20081006195446.1dc5a372@speedy> <48EA9223.8090700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:16195 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbYJFWuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:50:54 -0400
In-Reply-To: <48EA9223.8090700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Stephen Hemminger wrote:
> 
>> On Mon, 06 Oct 2008 18:02:39 +0200
>> Patrick McHardy <kaber@trash.net> wrote:
>>
>>> - the stack in fact doesn't require us to reduce the MTU of a VLAN
>>>    device as long as its within the physically possible MTU.
>>
>>
>> I think it should call change_mtu so userspace gets notified about both
>> changes.
> 
> 
> Agreed. But the question when to do automatic adjustments remains.

A matter of interpretation of the principle of least surprise right? 
Which is less surprising - that a VLAN's MTU drops to match that of the 
physical interface or that some traffic on the VLAN stops when the 
physical interface's MTU drops?

If physical interface MTUs are going to be bouncing around and VLANs get 
their MTUs changed then perhaps a VLAN needs both a desired and actual 
MTU setting.  The VLAN's interface would then be the minimum of the 
desired and actual MTU.  I suppose it isn't too unlike having both an 
administrative (desired) and operational (actual) interface state.

rick jones
