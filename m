From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/15] ehea: Remove unused tcp_end field in send WQ
Date: Wed, 11 May 2011 23:06:03 -0400 (EDT)
Message-ID: <20110511.230603.1390935245880337663.davem@davemloft.net>
References: <20110512005213.897432612@samba.org>
	<20110512005623.854973618@samba.org>
	<1305167473.6124.11.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756960Ab1ELDJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 23:09:22 -0400
In-Reply-To: <1305167473.6124.11.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 11 May 2011 19:31:13 -0700

> On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
>> plain text document attachment (ehea_22.patch)
>> The tcp_end field is not actually used by the hardware, so there
>> is no need to set it. 
>> +++ linux-net/drivers/net/ehea/ehea_qmr.h	2011-05-12 07:48:06.380382084 +1000
>> @@ -106,7 +106,7 @@ struct ehea_swqe {
>>  	u8 immediate_data_length;
>>  	u8 tcp_offset;
>>  	u8 reserved2;
>> -	u16 tcp_end;
>> +	u16 reserved2b;
>>  	u8 wrap_tag;
>>  	u8 descriptors;		/* number of valid descriptors in WQE */
>>  	u16 reserved3;
> 
> struct ehea_swqe isn't __packed.  Shouldn't it be?

Please don't mark it __packed unless absolutely necessary :-)
