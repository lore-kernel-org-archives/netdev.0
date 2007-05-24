From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.
Date: Thu, 24 May 2007 22:23:51 +0900
Message-ID: <20070524222026.F55B.NAKAM@linux-ipv6.org>
References: <11799066192758-git-send-email-nakam@linux-ipv6.org> <200705231154.33208.netdev@axxeo.de> <4654EEEB.1030603@linux-ipv6.org> <200705241036.09076.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:41742 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757272AbXEXNWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 09:22:44 -0400
In-Reply-To: <200705241036.09076.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ingo,

Ingo Oeser wrote:
> Masahide NAKAMURA schrieb:
>> Ingo Oeser wrote:
>>> What about  MODULE_ALIAS("xfrm-type-10-60") 
>>> and MODULE_ALIAS("xfrm-type-10-43") in mip6.c ?
> 
> Just replace your second patch ("Loadable module support")
> with one, which additionally adds these two lines to mip6.c ...
> 
>>> The aliases in modprobe.conf(5) should not be necessary then.
>>>
>>> If you are really ambitious you can even define a 
>>> MODULE_ALIAS_XFRM_TYPE macro in include/net/xfrm.h
>>> simliar to to MODULE_ALIAS_XFRM_MODE.
>> I prefer to use new macro like XFRM mode to unify XFRM
>> protocols i.e. esp[46].c, ah[46].c, ipcomp[46].c, and mip6.c
>> if we care about it. Can I add it as extensional patch
>> if nobody has a plan to do this yet?
> 
> 
> ... and provide a third patch to implement this cleanup.
> 
> That way there are no administrative changes required due to 
> any of your patches and we can defer the global cleanup, if it causes
> problems or conflicts with other patches in that area.
> 
> Does this sound like a plan?
> 

Thank you for the detailed instruction.

I intended to  ask the list is just in order
to avoid duplicated work; whether such work is
already queued by anyone's TODO to support module
aliases for each IPsec protocol or not.

Anyway, I'll provide the third patch for review,
which will be almost what you described.

-- 
Masahide NAKAMURA

