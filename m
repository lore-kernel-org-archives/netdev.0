From: Patrick McHardy <kaber@trash.net>
Subject: Re: updated tcatm patches for kernel/iproute 2.6.22
Date: Thu, 19 Jul 2007 15:22:09 +0200
Message-ID: <469F6581.3020400@trash.net>
References: <20070718210638.bs44zz4veowqf2kr@m.safari.iki.fi> <469E9B24.2080002@trash.net> <20070719113559.4y2z4bj4vwtglupw@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Mailing List <netdev@vger.kernel.org>
To: safari-kernel@safari.iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34426 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbXGSNZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 09:25:34 -0400
In-Reply-To: <20070719113559.4y2z4bj4vwtglupw@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sami Farin wrote:
> On Thu, Jul 19, 2007 at 00:58:44 +0200, Patrick McHardy wrote:
>   
>> Let me repeat again before we get in an endless discussion
>> again - I will NACK these patches until we have a solution
>> that works for all qdiscs.
>>     
>
> I googled for
> "Accurate packet scheduling for ATM" mchardy
> and found some threads from 2006.
>   
> http://www.mail-archive.com/netdev@vger.kernel.org/msg15706.html
> http://www.mail-archive.com/netdev@vger.kernel.org/msg21395.html
>
> So, Patrick:

Please keep me as receipient or CC when talking to me.

> 1) what is this "solution"?  do you have code?
>    or a brief explanation...

Simply calculcate the length including additional encapsulation
overhead at runtime. This allows all qdiscs to use the wire-length
in their calculations.

> 2) are you still working on this? is somebody else?
>   

Not to my knowledge.

> 3) do you have patches for iproute/kernel 2.6.22?

No.

> 4) if you have some patches, but they are not yet
>    complete, what else needs to be done?
>   

Not sure, its been a while since I posted some example patches.
Its not much work, probably quicker to start over.

