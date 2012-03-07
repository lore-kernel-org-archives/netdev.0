From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [PATCH] bridge: fix "entering disabled state" logging
Date: Wed, 07 Mar 2012 10:04:04 +0200
Message-ID: <4F571674.6000107@gmail.com>
References: <20120306142219.31783.30201.stgit@localhost.localdomain> <20120306.143323.1591818099708591757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from darkstar.wilibox.com ([85.255.61.7]:43346 "EHLO
	darkstar.wilibox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab2CGIEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:04:07 -0500
In-Reply-To: <20120306.143323.1591818099708591757.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2012 09:33 PM, David Miller wrote:
> From: Paulius Zaleckas<paulius.zaleckas@gmail.com>
> Date: Tue, 06 Mar 2012 16:22:19 +0200
>
>> Now we have:
>> eth0: link *down*
>> br0: port 1(eth0) entering *forwarding* state
>>
>> State should be logged *after* it was changed, not before.
>>
>> Reported-by: Zilvinas Valinskas<zilvinas@wilibox.com>
>> Signed-off-by: Paulius Zaleckas<paulius.zaleckas@gmail.com>
>
> This is intentional, this was a discussion about this.
>
> "Entering" means "about to" therefore we say it before it happens.

You have missed the whole point here... please look at dmesg output, I 
have bolded what you should pay attention to. It should say "entering 
disabled state" instead of "entering forwarding state".

However I do agree with you and Stephen that it should say "entered" and 
not "entering". I will send you patch changing this.

I will also resend this patch with better description.
