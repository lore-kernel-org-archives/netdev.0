From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] macvlan: propogate mtu changes
Date: Wed, 29 Oct 2008 22:06:51 +0100
Message-ID: <4908D06B.7010507@trash.net>
References: <20081029125912.002dbe9d@extreme>	<4908CF66.3030802@trash.net>	<4908CFFE.5000501@trash.net> <20081029.140522.29966751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43094 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875AbYJ2VGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:06:53 -0400
In-Reply-To: <20081029.140522.29966751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 29 Oct 2008 22:05:02 +0100
>
>   
>> Patrick McHardy wrote:
>>     
>>> Stephen Hemminger wrote:
>>>   
>>>       
>>>> If MTU of underlying real device is changed, propogate up to macvlan
>>>> pseudo devices.
>>>>     
>>>>         
>>> I'm going to do a similar patch for macvlan as I did for VLAN for
>>> the MTU settings (desired MTU/operational MTU).
>>>       
>> ... and add the rollback part from your patch to VLAN as well.
>>     
>
> So you want me to drop this second patch from Stephen from now?

Yes please, I'll send patches for both VLAN and macvlan MTU settings
later.

