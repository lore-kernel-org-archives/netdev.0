From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH 1/3] net: dcb: match dcb_app protocol field with
 802.1Qaz spec
Date: Sat, 05 Feb 2011 11:39:12 -0800
Message-ID: <4D4DA760.6090204@intel.com>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab> <20110131.204104.226756946.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20150 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab1BETjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Feb 2011 14:39:13 -0500
In-Reply-To: <20110131.204104.226756946.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2011 8:41 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Mon, 31 Jan 2011 14:00:49 -0800
> 
>> The dcb_app protocol field is a __u32 however the 802.1Qaz
>> specification defines it as a 16 bit field. This patch brings
>> the structure inline with the spec making it a __u16.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>  ...
>> @@ -101,7 +101,7 @@ struct ieee_pfc {
>>   */
>>  struct dcb_app {
>>  	__u8	selector;
>> -	__u32	protocol;
>> +	__u16	protocol;
>>  	__u8	priority;
>>  };
>>  
> 
> If we're going to do this, please fix this wasteful structure
> layout.  Put the "protocol" either first, or last, so that the
> structure size is 4 bytes, rather than something like 8.

OK I will fix this. Thanks
