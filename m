From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Compilation error on freshly pulled net-next?
Date: Fri, 05 Sep 2014 15:19:01 -0700
Message-ID: <540A36D5.4040007@hp.com>
References: <540A2F7F.8060809@hp.com> <20140905.150901.79089716373802484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:43007 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaIEWTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:19:40 -0400
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com [15.192.137.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id C1ABA608FE
	for <netdev@vger.kernel.org>; Fri,  5 Sep 2014 22:19:39 +0000 (UTC)
In-Reply-To: <20140905.150901.79089716373802484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2014 03:09 PM, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 05 Sep 2014 14:47:43 -0700
>
>> Looks like someone slipped a J in there and confused things:
>>
>>                 + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS +
>>                 IFLA_PORT_SELF */J + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>>                 + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
>>
>> (hopefully my mail client won't have mangled things too badly)
>>
>> What is odd though is a git diff after I've replaced that 'J' with a
>> return isn't giving me any output.
>
> That doesn't exist in my tree.

That's good.  Must have been some sort of glitch at my end, but what it 
could have been I've no clue.  I guess I'll just chalk it up to gremlins 
and see about doing a little light floor sweeping then.

rick
