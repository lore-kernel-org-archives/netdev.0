From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: add per bridge device controls for invoking iptables
Date: Fri, 02 Jul 2010 09:34:15 +0200
Message-ID: <4C2D9677.3000505@trash.net>
References: <1277729220-11775-1-git-send-email-kaber@trash.net>	<20100630142440.68adfdb1@nehalam> <20100630.142717.123424464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43682 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950Ab0GBHeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 03:34:16 -0400
In-Reply-To: <20100630.142717.123424464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 30 Jun 2010 14:24:40 -0700
>
>   
>> On Mon, 28 Jun 2010 14:47:00 +0200
>> kaber@trash.net wrote:
>>
>>     
>>> From: Patrick McHardy <kaber@trash.net>
>>>
>>> Support more fine grained control of bridge netfilter iptables invocation
>>> by adding seperate brnf_call_*tables parameters for each device using the
>>> sysfs interface. Packets are passed to layer 3 netfilter when either the
>>> global parameter or the per bridge parameter is enabled.
>>>
>>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>>>       
>> Looks like a good idea.
>>
>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>>     
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
> Patrick since this is mostly netfilter'ish, please toss it into one
> of your trees.
>   

Will do, thanks.
