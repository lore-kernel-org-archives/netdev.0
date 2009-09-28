From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3 and Broadcom PHY driver
Date: Mon, 28 Sep 2009 23:52:54 +0200
Message-ID: <4AC13036.8030506@embedded-sol.com>
References: <4ABE8862.3060308@embedded-sol.com>	<20090928205226.GB12652@xw6200.broadcom.net>	<4AC1223B.8070903@embedded-sol.com> <20090928.141527.193009676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:36869 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383AbZI1Vwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 17:52:55 -0400
In-Reply-To: <20090928.141527.193009676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David
David Miller wrote:
> From: Felix Radensky <felix@embedded-sol.com>
> Date: Mon, 28 Sep 2009 22:53:15 +0200
>
>   
>> Hi, Matt
>>
>> Matt Carlson wrote:
>>     
>>> On Sat, Sep 26, 2009 at 02:32:18PM -0700, Felix Radensky wrote:
>>>   
>>> Is the broadcom module also compiled into the kernel?
>>>
>>>   
>>>       
>> Yes.
>>     
>
> I bet this is all because the tg3 driver is linked into the kernel
> before the PHY layer and drivers subdirectory or something like that.
>
> Link order determines the order in which built-in initializations
> occur (within the same init type).
>   

Yes, moving CONFIG_TIGON3 right after CONFIG_PHYLIB in drivers/net/Makefile
fixes the problem for me.

Thanks a lot.

Felix.

