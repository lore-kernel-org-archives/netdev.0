From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 10:57:47 +0100
Message-ID: <49AE509B.3000305@trash.net>
References: <20090228180541.GA729@jukie.net> <20090303.234327.81716668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64522 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbZCDJ5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 04:57:52 -0500
In-Reply-To: <20090303.234327.81716668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Bart Trojanowski <bart@jukie.net>
> Date: Sat, 28 Feb 2009 13:05:41 -0500
> 
>> 2.6.29-rc* introduces a bug that causes a crash when a vlan is put into
>> another vlan, so called vlan trunking or QinQ.
>>
>> I can reproduce it reliably with:
>>
>>   $ modprobe 8021q
>>   $ vconfig add eth1 5
>>   $ ifconfig eth1.5 up
>>   $ vconfig add eth1.5 4
> 
> Stephen please fix this.

I'm maintaining vlan :) I haven't been able to look into this yet,
but I should be later today.


