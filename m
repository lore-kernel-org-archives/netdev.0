From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.
Date: Thu, 24 May 2007 10:48:27 +0900
Message-ID: <4654EEEB.1030603@linux-ipv6.org>
References: <11799066192758-git-send-email-nakam@linux-ipv6.org> <200705231154.33208.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:39242 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757099AbXEXBs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 21:48:26 -0400
In-Reply-To: <200705231154.33208.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> nakam@linux-ipv6.org schrieb:
>> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
>>
>> This patch makes MIPv6 loadable module named "mip6".
>>
>> Here is a modprobe.conf(5) example to load it automatically
>> when user application uses XFRM state for MIPv6:
>>
>> alias xfrm-type-10-43 mip6
>> alias xfrm-type-10-60 mip6
> 
> What about  MODULE_ALIAS("xfrm-type-10-60") 
> and MODULE_ALIAS("xfrm-type-10-43") in mip6.c ?
> 
> The aliases in modprobe.conf(5) should not be necessary then.
> 
> If you are really ambitious you can even define a 
> MODULE_ALIAS_XFRM_TYPE macro in include/net/xfrm.h
> simliar to to MODULE_ALIAS_XFRM_MODE.

I prefer to use new macro like XFRM mode to unify XFRM
protocols i.e. esp[46].c, ah[46].c, ipcomp[46].c, and mip6.c
if we care about it. Can I add it as extensional patch
if nobody has a plan to do this yet?


 > Please be sure to discuss CC Herbert Xu then.

# CC-ed.

Regards,

-- 
Masahide NAKAMURA
