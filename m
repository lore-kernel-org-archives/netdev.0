From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH] net: fix checking boundary of valid vlan id
Date: Mon, 31 Dec 2012 22:06:43 +1030
Message-ID: <186CBD58-5106-4FCD-8C73-E4EC84C3A303@gdt.id.au>
References: <1356848931-22193-1-git-send-email-akong@redhat.com> <20121230122542.GC11727@breakpoint.cc>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: akong@redhat.com, netdev@vger.kernel.org, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:49718 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750935Ab2LaMU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 07:20:59 -0500
In-Reply-To: <20121230122542.GC11727@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 30/12/2012, at 10:55 PM, Florian Westphal wrote:

> akong@redhat.com <akong@redhat.com> wrote:
>> From: Amos Kong <akong@redhat.com>
>> 
>> 4096 is not a valid vlan id.
> 
> True.
> 
> But why shouldn't users be allowed to check for frames
> with reserved value


It may be a valid VLAN ID, or it may not. The meaning of FFF is reserved for vendor use, which doesn't preclude a vendor using it as a (non-interoperable) VLAN identifier. Many vendor's products treat 4096 as they do any other VID.

It's up to Linux if it cares to treat 4096 as a VLAN or as something else.

In any case, Florian's point is good: an ethernet-layer firewall should be able to trigger on any value of VID, and particularly one which should not be seen from some vendor's gear.

-glen