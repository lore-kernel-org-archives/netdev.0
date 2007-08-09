From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Thu, 9 Aug 2007 11:16:12 -0700
Message-ID: <OF26E08E6B.9C6CD04B-ON87257332.00635BE5-88257332.00642BE1@us.ibm.com>
References: <adawsw4mwcw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33497 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbXHISRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 14:17:11 -0400
In-Reply-To: <adawsw4mwcw.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Roland,

> Shirley, I think it would still be useful to run benchmarks of IPoIB
> on ehca with Dave's NAPI patches, both V5 that changed the "missed
> event" behavior and V6 that didn't.  At least I'm curious to know how
> much the difference is.
> 
>  - R.

The performance difference was huge before. Most of the time the poll more 
method was only polling one packet again and agin. 
Yes, we will definitely run the performance measurement, but I have 
lowered this task priority since Dave has V6 version. Actually IPoIB is 
not the only one device using rescheduling instead of polling more for 
NAPI. I think it's not a bad idea to do so.

Thanks
Shirley 
