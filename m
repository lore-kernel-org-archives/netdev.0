From: David Miller <davem@davemloft.net>
Subject: Re: [iproute2 net-next] ip route: Add RTM_F_LOOKUP_TABLE flag and
 show table id
Date: Mon, 21 Sep 2015 15:03:46 -0700 (PDT)
Message-ID: <20150921.150346.926573540048522271.davem@davemloft.net>
References: <56007695.3070003@cumulusnetworks.com>
	<20150921.145800.1946648892912159723.davem@davemloft.net>
	<56007E94.8000506@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756728AbbIUWDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 18:03:47 -0400
In-Reply-To: <56007E94.8000506@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 21 Sep 2015 16:03:00 -0600

> On 9/21/15 3:58 PM, David Miller wrote:
>> I think if it always gave MAIN in older kernels, iproute should
>> continue
>> to do so.
>>
>> You can't just remove the table ID output just because you disagree
>> with
>> the semantics given by old kernels.
>>
> 
> Current semantics are maintained. Kernel was hardcoded to return main;
> iproute2 was hardcoded to not show main.

Since iproute2 always showed MAIN, it should conitnue to do so when
run on older kernels.

And again this is regardless of whether you disagree with those
semantics or not.
