From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] tun: Fix/rewrite packet filtering logic
Date: Tue, 22 Jul 2008 21:45:30 -0700
Message-ID: <4886B76A.6000907@qualcomm.com>
References: <1215852774-23974-1-git-send-email-maxk@qualcomm.com>	<4886703B.5090609@garzik.org> <20080722.171111.267353608.davem@davemloft.net> <48867BC3.3070506@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, sjackman@gmail.com,
	linuxkernel@bristyle.com,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:63339 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbYGWEpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 00:45:30 -0400
In-Reply-To: <48867BC3.3070506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jeff Garzik wrote:
> David Miller wrote:
>> From: Jeff Garzik <jeff@garzik.org>
>> Date: Tue, 22 Jul 2008 19:41:47 -0400
>>
>>> looks mostly OK, but stuff like the above should be
>>>
>>>     (void __user *) arg
>>>
>>> Did you check this with sparse (Documentation/sparse.txt)?

Ah. No I did not check it with sparse.

>>
>> Jeff, I already added this particular patch to the tree
>> a week or so ago.
> 
> Yeah, later on in my queue were the fixes.

I'm not sure I'm following. What fixes ? Are you talking about fixing sparse
warnings or something else ?

Max



