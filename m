From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Sat, 28 Apr 2007 13:28:18 -0400
Message-ID: <46338432.5060105@garzik.org>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>	<463363ED.3050307@garzik.org> <20070429.022428.71103613.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52736 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161876AbXD1R2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 13:28:23 -0400
In-Reply-To: <20070429.022428.71103613.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> On Sat, 28 Apr 2007 11:10:37 -0400, Jeff Garzik <jeff@garzik.org> wrote:
>>>  static unsigned int netcard_portlist[] __initdata = {
>>> -	0x300, 0x280, 0x320, 0x340, 0x360, 0x380, 0
>>> +#if defined(CONFIG_ISA) || defined(CONFIG_M32R)
>>> +	0x300, 0x280, 0x320, 0x340, 0x360, 0x380,
>>> +#endif
>>> +	0
>> This looks a bit strange, and perhaps more difficult to maintain long term.
>>
>> I would suggest creating a NEEDS_PORTLIST cpp macro at the top of ne.c, 
>> to be defined or undefined based on CONFIG_xxx symbols.  Then, down in 
>> the code itself, conditionally include or exclude all portlist related 
>> data tables and code.
>>
>> Sound sane?
> 
> Sure.  Do you mean something like this?

Correct.

	Jeff


