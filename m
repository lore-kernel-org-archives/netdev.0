From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Mon, 16 Jul 2007 13:10:55 +0400
Message-ID: <469B361F.6060604@openvz.org>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <46961F21.7030409@trash.net> <469629FD.4030709@openvz.org> <46962B72.3070000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:48566 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755836AbXGPJLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 05:11:06 -0400
In-Reply-To: <46962B72.3070000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> Patrick McHardy wrote:
>>
>>>> +
>>>> +	if (tb[IFLA_IFNAME])
>>>> +		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
>>>> +	else
>>>> +		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
>>>
>>> Does this work? The other device is not registered at this time, so I
>>> think the allocated names could clash ..
>>
>> Oh! And one more thing, I've just thought about - even two devices with
>> similar name would be ok when we have a namespaces and one of the ends of
>> this tunnel is to be in some other namespace rather that the init one.
> 
> 
> Yes, but we don't have network namespaces yet. Which brings up another
> question: is this driver of any use without namespaces?
> 
> 

Sure. For example, you can join two bridges together.

Thanks,
Pavel
