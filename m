From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 4/7] cxgb3 - Update FW to 4.1
Date: Sat, 26 May 2007 16:10:47 -0700
Message-ID: <4658BE77.1030202@chelsio.com>
References: <20070526230003.12156.10521.stgit@localhost.localdomain> <200705270105.10188.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15068 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbXEZXL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 19:11:27 -0400
In-Reply-To: <200705270105.10188.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Sunday 27 May 2007 01:00:04 divy@chelsio.com wrote:
>   
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Bump FW version to 4.1.
>> Modify chip tuning in consequence.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>> ---
>>     
>
>   
>> @@ -2496,11 +2500,11 @@ static void __devinit init_mtus(unsigned
>>  	 * it can accomodate max size TCP/IP headers when SACK and timestamps
>>  	 * are enabled and still have at least 8 bytes of payload.
>>  	 */
>> -	mtus[0] = 88;
>> -	mtus[1] = 256;
>> -	mtus[2] = 512;
>> -	mtus[3] = 576;
>> -	mtus[4] = 808;
>> +	mtus[1] = 88;
>> +	mtus[1] = 88;
>>     
>
> looks like a typo.
>   

Good catch. The intent was to set mtu[0] and mtu[1] to 88.
I'll resubmit this patch.
Thanks!

Divy
