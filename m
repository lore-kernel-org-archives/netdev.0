From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] Add new timeval_to_sec function
Date: Tue, 24 Jul 2007 09:45:47 +0530
Message-ID: <46A57CF3.6040505@linux.vnet.ibm.com>
References: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com> <46A48FFD.4070902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36556 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbXGXEPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 00:15:33 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l6O39b9J008348
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 23:09:37 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6O4FWiO258216
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 22:15:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6O4FVGq031708
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 22:15:32 -0600
In-Reply-To: <46A48FFD.4070902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Varun Chandramohan wrote:
>   
>>  /**
>> + * timeval_to_sec - Convert timeval to seconds
>> + * @tv:         pointer to the timeval variable to be converted
>> + *
>> + * Returns the seconds representation of timeval parameter.
>> + */
>> +static inline time_t timeval_to_sec(const struct timeval *tv)
>> +{
>> +	return (tv->tv_sec + (tv->tv_usec + 500000)/1000000);
>> +}
>>     
>
>
> I don't think you should round down timeout values.
>   
Can you elaborate on that? As per the RFC of MIB ,we need only seconds
granularity. Taking that as the case i dont understand why round down
should not be done?

Regards,
Varun
