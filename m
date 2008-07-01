From: Patrick McHardy <kaber@trash.net>
Subject: Re: v2 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Tue, 01 Jul 2008 11:57:13 +0200
Message-ID: <4869FF79.1060803@trash.net>
References: <4869A251.108@cn.fujitsu.com> <4869A42A.2010009@cn.fujitsu.com> <4869FB80.8050107@trash.net> <4869FDB3.1040400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63628 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbYGAJ5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 05:57:16 -0400
In-Reply-To: <4869FDB3.1040400@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-7-1 17:40:
>> Wang Chen wrote:
>>> -    dev_set_allmulti(dev, +1);
>>> +    err = dev_set_allmulti(dev, 1);
>>> +    if (err)
>>> +        return err;
>> Missing error handling for VIFF_REGISTER and VIFF_TUNNEL case.
>>
> 
> will do.

Thanks. I didn't check the other patches (except those
I ACKed). Please also verify wether they all do error
handling properly.

> seems 
>>      if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
> should do error handling too.

Doesn't seem necessary, it doesn't take a reference or has
any other sideeffects.

