From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: add the correct LRO status at dev->features
Date: Mon, 06 Dec 2010 09:33:12 -0800 (PST)
Message-ID: <20101206.093312.71114491.davem@davemloft.net>
References: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com>
	<20101206084824.637d6b29@nehalam>
	<4CFD15F6.7040609@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47356
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752986Ab0LFRcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 12:32:45 -0500
In-Reply-To: <4CFD15F6.7040609@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Mon, 06 Dec 2010 14:57:26 -0200

> On 12/06/2010 02:48 PM, Stephen Hemminger wrote:
>> On Mon,  6 Dec 2010 14:39:42 -0200
>> leitao@linux.vnet.ibm.com wrote:
>>
>>> Currently ehea is not setting NETIF_F_LRO, and it is not providing
>>> a callback for get_flags on ethtool. This patch fixes it.
>>>
>>> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
>>
>> More importantly, ehea does not support set_flags to disable LRO.
> Correct, currently LRO is a module parameter. I have an item in my
> TODO list to implement set_flags, and thus, the LRO scheme.
> 
> So, if you prefer I can send this patch with the future set_flags
> ones. But, for now, this patch allows the user to check when LRO is
> enabled. As it is today, it shows that LRO is disabled all the time.
> 
> Anyway, you choose what is the best option.

Your options are: 1) send a set_flags patch now 2) rip LRO support
completely out of the ehea driver.

The feature is implemented improperly, and as such we have every right
to forcefully disable it or remove it until it is fixed to function
correctly.
