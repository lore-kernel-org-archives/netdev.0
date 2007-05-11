From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch 4/8] Use menuconfig objects: SCTP
Date: Fri, 11 May 2007 10:12:59 -0400
Message-ID: <464479EB.5070002@hp.com>
References: <200705110553.l4B5rkFq007858@shell0.pdx.osdl.net> <4644736C.4000808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, jengelh@linux01.gwdg.de, jengelh@gmx.de,
	sri@us.ibm.com
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:60186 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403AbXEKONH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 10:13:07 -0400
In-Reply-To: <4644736C.4000808@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley wrote:
> akpm@linux-foundation.org wrote:
>> diff -puN net/sctp/Kconfig~use-menuconfig-objects-sctp net/sctp/Kconfig
>> --- a/net/sctp/Kconfig~use-menuconfig-objects-sctp
>> +++ a/net/sctp/Kconfig
>> @@ -2,11 +2,9 @@
>>  # SCTP configuration
>>  #
>>  
>> -menu "SCTP Configuration (EXPERIMENTAL)"
>> -    depends on INET && EXPERIMENTAL
>> -
>> -config IP_SCTP
>> +menuconfig IP_SCTP
>>      tristate "The SCTP Protocol (EXPERIMENTAL)"
>> +    depends on NET && EXPERIMENTAL
>>      depends on IPV6 || IPV6=n
>>      select CRYPTO if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
>>      select CRYPTO_HMAC if SCTP_HMAC_SHA1 || SCTP_HMAC_MD5
> 
> This just changed "INET && EXPERIMENTAL" to "NET && EXPERIMENTAL", don't
> know if that was intended.
> 
> -Brian

Thanks Brian.   This is a bug.  This should use INET.

-vlad
