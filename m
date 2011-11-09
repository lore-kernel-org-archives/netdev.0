From: David Miller <davem@davemloft.net>
Subject: Re: dst->obsolete has become pointless
Date: Wed, 09 Nov 2011 14:20:44 -0500 (EST)
Message-ID: <20111109.142044.1307358041881082836.davem@davemloft.net>
References: <20111108.122020.1080743546477280623.davem@davemloft.net>
	<20111108.135901.1506278599930259562.davem@davemloft.net>
	<1320842948.6923.3.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab1KITVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 14:21:03 -0500
In-Reply-To: <1320842948.6923.3.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 09 Nov 2011 04:49:08 -0800

> On Tue, 2011-11-08 at 13:59 -0500, David Miller wrote:
>> net: Kill pointless and misleading checks on dst->obsolete.
> []
>> Therefore rename it to dst->freed, and make it take on only the values
>> "0" and "1".
>> diff --git a/include/net/dst.h b/include/net/dst.h
> []
>> @@ -55,7 +55,7 @@ struct dst_entry {
>>  #define DST_NOCOUNT		0x0020
>>  
>>  	short			error;
>> -	short			obsolete;
>> +	unsigned short		freed;
> 
> perhaps
> 	bool freed;
> 	bool __pad3;
> just to mark the available space a bit more obviously.

Hmmm, what is a bool's defined type anyways?  It is a char on every
architecture and ABI?
