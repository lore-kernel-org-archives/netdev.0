From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 13:45:35 -0500
Message-ID: <49D3B64F.6070703@codemonkey.ws>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:23970 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933581AbZDASpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 14:45:41 -0400
In-Reply-To: <20090401170103.GU11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Wed, Apr 01, 2009 at 10:19:49AM -0400, Gregory Haskins wrote:
>   
>>>>     
>>>>         
>>> But surely you must have some specific use case in mind? Something
>>> that it does better than the various methods that are available
>>> today. Or rather there must be some problem you're trying
>>> to solve. I'm just not sure what that problem exactly is.
>>>   
>>>       
>> Performance.  We are trying to create a high performance IO infrastructure.
>>     
>
> Ok. So the goal is to bypass user space qemu completely for better
> performance. Can you please put this into the initial patch
> description?
>   

FWIW, there's nothing that prevents in-kernel back ends with virtio so 
vbus certainly isn't required for in-kernel backends.

That said, I don't think we're bound today by the fact that we're in 
userspace.  Rather we're bound by the interfaces we have between the 
host kernel and userspace to generate IO.  I'd rather fix those 
interfaces than put more stuff in the kernel.

Regards,

Anthony Liguori
