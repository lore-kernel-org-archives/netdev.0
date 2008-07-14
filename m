From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Mon, 14 Jul 2008 09:05:06 +0800
Message-ID: <487AA642.2030007@cn.fujitsu.com>
References: <48718014.4030009@cn.fujitsu.com> <48718172.8070404@cn.fujitsu.com> <4871FC5C.9030106@trash.net> <4873364F.1030709@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65427 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753980AbYGNBKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jul 2008 21:10:13 -0400
In-Reply-To: <4873364F.1030709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-8 17:41:
> Patrick McHardy said the following on 2008-7-7 19:22:
>>>      case 0:
>>>          dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
>>>          if (!dev)
>>>              return -EADDRNOTAVAIL;
>>>          dev_put(dev);
>>> +        err = dev_set_allmulti(dev, 1);
>>> +        if (err)
>>> +            return err;
>> Also looks like a use after free, but again, one that is
>> already present without your patch.
>>
> 
> Here is the patch for fixing use after free.
> It fixes both ipv4 and ipv6 side and on top of my patches.
> This patch will be the 6/8 of the series.
> 

David, Patrick.
Please ignore this one.

