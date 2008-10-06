From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: propogate MTU changes
Date: Tue, 07 Oct 2008 00:33:07 +0200
Message-ID: <48EA9223.8090700@trash.net>
References: <20081006173024.2741cc01@speedy>	<48EA369F.3090306@trash.net> <20081006195446.1dc5a372@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56104 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbYJFWdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:33:13 -0400
In-Reply-To: <20081006195446.1dc5a372@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 06 Oct 2008 18:02:39 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> - the stack in fact doesn't require us to reduce the MTU of a VLAN
>>    device as long as its within the physically possible MTU.
> 
> I think it should call change_mtu so userspace gets notified about both
> changes.

Agreed. But the question when to do automatic adjustments remains.


