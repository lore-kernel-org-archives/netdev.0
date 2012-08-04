From: Ali Ayoub <ali@mellanox.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Fri, 03 Aug 2012 17:02:35 -0700
Message-ID: <501C669B.2030303@mellanox.com>
References: <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com> <87boitz044.fsf@xmission.com> <501C3527.6060809@mellanox.com> <20120803.143315.151094375569109262.davem@davemloft.net> <501C5328.4060301@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ogerlitz@mellanox.com, roland@kernel.org,
	netdev@vger.kernel.org, sean.hefty@intel.com, erezsh@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mellanox.cgrafx.com ([67.192.191.215]:44151 "EHLO
	mellanox.cgrafx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab2HDACh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 20:02:37 -0400
In-Reply-To: <501C5328.4060301@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/2012 3:39 PM, Ali Ayoub wrote:
> On 8/3/2012 2:33 PM, David Miller wrote:
>> From: Ali Ayoub <ali@mellanox.com>
>> Date: Fri, 03 Aug 2012 13:31:35 -0700
>>
>>> With eIPoIB architecture, the VM sees standard Ethernet emulator,
>>> allowing the administrator to enslave eIPoIB PIF to the vSwitch/vBridge
>>> as if it was standard Ethernet. Other approaches that exposes IB QP to
>>> the VM (with w/o bypassing the kernel) won't be possible with the
>>> current emulators and management tools.
>>
>> So then fix the emulators and management tools to handle IB instead
>> of adding this bogus new protocol?
>>
>> This new protocol seems to exist only because you don't want to have
>> to enhance the emulators and tools, and I'm sorry that isn't a valid
>> reason to do something like this.
> 
> This driver exists to allow the user to have an Ethernet interface on
> top of a high-speed InfiniBand (IB) interconnect.
> Users would like to use sockets API from the VM without re-writing their
> applications on top of IB verbs, this driver meant to allow such a user
> to do so.
> 
> Exposing IB emulators and having IB support in the management tools for
> the VM/Hypervisor won't address the usecases that this driver meant for.
> 
> With this driver, existing VMs, and their existing IP applications, can
> run as-is on InfiniBand network.

This driver exists to allow the user to have an Ethernet interface on
top of a high-speed InfiniBand (IB) interconnect.
Users would like to use sockets API from the VM without re-writing their
applications on top of IB verbs, this driver meant to allow such a user
to do so.

Exposing IB emulators and having IB support in the management tools for
the VM/Hypervisor won't address the usecases that this driver meant for.

With this driver, existing VMs, and their existing IP applications, can
run as-is on InfiniBand network.
