From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xtables: make XT_ALIGN() usable in exported headers
Date: Thu, 01 Apr 2010 14:06:40 +0200
Message-ID: <4BB48C50.2000000@trash.net>
References: <n2ib6fcc0a1004010502z8c25a68cg11c5aa2f90ad4826@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andreas Henriksson <andreas@fatal.se>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50911 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab0DAMGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:06:42 -0400
In-Reply-To: <n2ib6fcc0a1004010502z8c25a68cg11c5aa2f90ad4826@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> On Thu, Apr 1, 2010 at 1:50 PM, Patrick McHardy <kaber@trash.net> wrote:
>> I can't think of anything but to restore the XT_ALIGN macro.
>> We could add a XT_ALIGN definition to xtables.h, but that might
>> still leave problems for other users.
>>
>> Alexey, do you have any better suggestions?
> 
> I like __KERNEL_ALIGN trick.
> 
> Sorry for attachment, my patch sending facility is broke.
> Tested on iptables compilation.
> 

Seems fine to me, thanks. I'll wait a bit for others to comment.
