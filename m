From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000, e1000e valid-addr fixes
Date: Thu, 01 Nov 2007 14:47:55 -0400
Message-ID: <472A1F5B.9060401@garzik.org>
References: <471E99E8.6030404@garzik.org>	<20071023.180744.115914004.davem@davemloft.net>	<471EABEE.8030900@garzik.org> <20071023.192313.115635750.davem@davemloft.net> <472A1526.8070208@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	davej@redhat.com, ajax@redhat.com, linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55602 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbXKASr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 14:47:59 -0400
In-Reply-To: <472A1526.8070208@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> David Miller wrote:
>> From: Jeff Garzik <jeff@garzik.org>
>> Date: Tue, 23 Oct 2007 22:20:30 -0400
>>
>>> David Miller wrote:
>>>> From: Jeff Garzik <jeff@garzik.org>
>>>> Date: Tue, 23 Oct 2007 21:03:36 -0400
>>>>
>>>>> I'm wondering if there is a way to avoid adding
>>>>>
>>>>> 	if (!is_valid_ether_addr(dev->dev_addr))
>>>>> 		return -EINVAL;
>>>>>
>>>>> to every ethernet driver's ->open() hook.
>>>> The first idea I get is:
>>>>
>>>> 1) Create netdev->validate_dev_addr().
>>>>
>>>> 2) If it exists, invoke it before ->open(), abort
>>>>    and return if any errors signaled.
>>>>
>>>> etherdev init hooks up a function that does the above
>>>> check, which allows us to avoid editing every ethernet
>>>> driver
>>>>
>>>> What do you think?
>>> Seems sane to me.  Something like this (attached)?
>> Looks great:
>>
>> Acked-by: David S. Miller <davem@davemloft.net>
> 
> I like it.
> 
> Should I start sending patches to remove the checks from e1000/e1000e/ixgb/ixgbe
> already (to David, I assume?)?

Send the patches to me like normal...

	Jeff



