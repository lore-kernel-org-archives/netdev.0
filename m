From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [patch 4/8] Use menuconfig objects: SCTP
Date: Fri, 11 May 2007 17:22:36 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0705111722000.6426@yvahk01.tjqt.qr>
References: <200705110553.l4B5rkFq007858@shell0.pdx.osdl.net> <4644736C.4000808@hp.com>
 <464479EB.5070002@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Brian Haley <brian.haley@hp.com>, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, sri@us.ibm.com
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer.gwdg.de ([134.76.10.26]:56258 "EHLO mailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755653AbXEKP0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 11:26:36 -0400
In-Reply-To: <464479EB.5070002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 11 2007 10:12, Vlad Yasevich wrote:
>Brian Haley wrote:
>> akpm@linux-foundation.org wrote:
>>> diff -puN net/sctp/Kconfig~use-menuconfig-objects-sctp net/sctp/Kconfig
>>> --- a/net/sctp/Kconfig~use-menuconfig-objects-sctp
>>> +++ a/net/sctp/Kconfig
>>> @@ -2,11 +2,9 @@
>>>  # SCTP configuration
>>>  #
>>>  
>>> -menu "SCTP Configuration (EXPERIMENTAL)"
>>> -    depends on INET && EXPERIMENTAL
>>> -
>>> -config IP_SCTP
>>> +menuconfig IP_SCTP
>>>      tristate "The SCTP Protocol (EXPERIMENTAL)"
>>> +    depends on NET && EXPERIMENTAL
>>>      depends on IPV6 || IPV6=n
>>>      select CRYPTO if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
>>>      select CRYPTO_HMAC if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
>> 
>> This just changed "INET && EXPERIMENTAL" to "NET && EXPERIMENTAL", don't
>> know if that was intended.
>
>Thanks Brian.   This is a bug.  This should use INET.

Nobody's perfect :p


	Jan
-- 
