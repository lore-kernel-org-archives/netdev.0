From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 19:26:42 +0200
Message-ID: <4BED87D2.3070308@trash.net>
References: <C812D414.3180C%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49429 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab0ENR0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 13:26:43 -0400
In-Reply-To: <C812D414.3180C%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Feldman wrote:
> On 5/14/10 9:42 AM, "Patrick McHardy" <kaber@trash.net> wrote:
> 
>> Arnd Bergmann wrote:
>>> Maybe a better structure would be to separate the two cases, also allowing
>>> a port profile to be associated with both the PF and with each of its VFs?
>>>
>>> Something like this:
>>>
>>> [IFLA_NUM_VF]
>>> [IFLA_VF_PORTS]
>>>   [IFLA_VF_PORT]
>>>     [IFLA_VF_PORT_*], ...
>>>   [IFLA_VF_PORT]
>>>     [IFLA_VF_PORT_*], ...
>>> [IFLA_PORT_SELF]
>>>   [IFLA_VF_PORT_*], ...
>> That would also be fine.
> 
> I want to make sure I've got this right before starting on ver8 of patch:
> 
>     - we'll use the layout listed above
> 
>     - RTM_SETLINK msg includes the full nested layout
> 
>         - contains IFLA_VF_PORTs for all VFs of a PF
>         - OR, contains IFLA_PORT_SELF if PF is it's own VF
> 
>         - it's up to the receiver to compare for changes for each VF
> 
>     - RTM_GETLINK msg includes the full nested layout
> 
>         - same rules as RTM_SETLINK above
> 
> I think we should redo the other IFLA_VF_xxx msgs in the same style.  I'm
> not going to tackle that for IFLA_VF_PORTS patch, but it would be a good
> followup patch.

Agreed.

> Do we have a plan?

That sounds good to me. If you have any netlink related questions,
just let me know.
