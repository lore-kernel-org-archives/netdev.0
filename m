From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2/7] cxgb3 - private ioctl cleanup
Date: Thu, 22 Feb 2007 04:34:34 -0800
Message-ID: <45DD8DDA.8060303@chelsio.com>
References: <20070222115925.10001.61276.stgit@localhost.localdomain> <20070222.210618.134161490.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	yoshfuji@linux-ipv6.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:2553 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945986AbXBVMeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 07:34:50 -0500
In-Reply-To: <20070222.210618.134161490.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshfuji,
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Clean up some private ioctls.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>> ---
>>
>>  drivers/net/cxgb3/cxgb3_ioctl.h |   21 ++++-------------
>>  drivers/net/cxgb3/cxgb3_main.c  |   48 +++------------------------------------
>>  2 files changed, 9 insertions(+), 60 deletions(-)
>>
>> diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/cxgb3/cxgb3_ioctl.h
>> index a942818..42d4bf6 100644
>> --- a/drivers/net/cxgb3/cxgb3_ioctl.h
>> +++ b/drivers/net/cxgb3/cxgb3_ioctl.h
>> @@ -36,28 +36,17 @@
>>   * Ioctl commands specific to this driver.
>>   */
>>  enum {
>> -	CHELSIO_SETREG = 1024,
>> -	CHELSIO_GETREG,
>> -	CHELSIO_SETTPI,
>> -	CHELSIO_GETTPI,
>> -	CHELSIO_GETMTUTAB,
>> +	CHELSIO_GETMTUTAB = 1024,
>>  	CHELSIO_SETMTUTAB,
>> -	CHELSIO_GETMTU,
>> -	CHELSIO_SET_PM,
>> -	CHELSIO_GET_PM,
>> -	CHELSIO_GET_TCAM,
>> -	CHELSIO_SET_TCAM,
>> -	CHELSIO_GET_TCB,
>>  	CHELSIO_GET_MEM,
>>  	CHELSIO_LOAD_FW,
>> -	CHELSIO_GET_PROTO,
>> -	CHELSIO_SET_PROTO,
>>  	CHELSIO_SET_TRACE_FILTER,
>> -	CHELSIO_SET_QSET_PARAMS,
>>  	CHELSIO_GET_QSET_PARAMS,
>> -	CHELSIO_SET_QSET_NUM,
>> +	CHELSIO_SET_QSET_PARAMS,
>>  	CHELSIO_GET_QSET_NUM,
>> -	CHELSIO_SET_PKTSCHED,
>> +	CHELSIO_SET_QSET_NUM,
>> +	CHELSIO_GET_PM,
>> +	CHELSIO_SET_PM,
>>  };
>>  
>>     
>
> I disagree. This is very bad.
>
> 1. Please do do change the values.
> 2. Explain why you are going to kill these ioctls.
>   
Jeff and Arjan have required that most of these ioctls go.
Please read:
http://marc.theaimsgroup.com/?l=linux-netdev&m=117029584904193&w=2

Cheers,
Divy
