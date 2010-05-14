From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 20:46:29 +0200
Message-ID: <4BED9A85.4080507@trash.net>
References: <C812DA73.31839%scofeldm@cisco.com> <4BED91D0.5020407@trash.net> <20100514182526.GO5798@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, Arnd Bergmann <arnd@arndb.de>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50722 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574Ab0ENSqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 14:46:30 -0400
In-Reply-To: <20100514182526.GO5798@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Wright wrote:
> * Patrick McHardy (kaber@trash.net) wrote:
>> Scott Feldman wrote:
>>> On 5/14/10 10:29 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
>>>
>>>>> I think we should redo the other IFLA_VF_xxx msgs in the same style.  I'm
>>>>> not going to tackle that for IFLA_VF_PORTS patch, but it would be a good
>>>>> followup patch.
>>>> I fear it's too late for that now. While we have not yet released 2.6.34
>>>> and 2.6.33 does not contain the broken message, it's extremely late in the
>>>> stabilization phase of v2.6.34, so I doubt that there is still a chance for
>>>> that at this point.
>>> That's too bad.  I wish Patrick's objections were honored and then we
>>> wouldn't have followed that broken model!  Can the broken msgs be disabled
>>> somehow for 2.6.34?  Keep the definitions in if_link.h but fail the SET/GET
>>> actions in rtnetlink.c?
>> That would be a possibility. Unfortunately I don't think we can fix
>> this in a backwards compatible way.
> 
> $ git describe --contains ebc08a6f47ee76ecad8e9f26c26e6ec9b46ca659
> v2.6.34-rc1~233^2~336
> 
> It's not released yet?

Correct, it was added in 2.6.34-rc.
