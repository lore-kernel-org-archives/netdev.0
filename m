From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Sat, 25 Nov 2006 16:16:06 -0700
Message-ID: <m1bqmvnmmh.fsf@ebiederm.dsl.xmission.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77F0F698@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <hadi@cyberus.ca>, "Daniel Lezcano" <dlezcano@fr.ibm.com>,
	"Dmitry Mishin" <dim@openvz.org>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	<netdev@vger.kernel.org>,
	"Linux Containers" <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:16521 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S935098AbWKYXRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Nov 2006 18:17:42 -0500
To: "Leonid Grossman" <Leonid.Grossman@neterion.com>
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77F0F698@nekter> (Leonid
	Grossman's message of "Sat, 25 Nov 2006 17:17:03 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Leonid Grossman" <Leonid.Grossman@neterion.com> writes:

> I did not mean kernel bypass, just L2 hw channels that for 
> all practical purposes act as separate NICs - 
> different MAC addresses, no blocking, independent reset, etc.

Yes. Nearly all of what you need for safe kernel bypass.

>> In the worst case I might need someone to go as far as the 
>> Grand Unified Lookup to remove all of the overheads.  Except 
>> for distributing the work load more evenly across the machine 
>> with separate interrupts and the like I see no need for 
>> separate hardware channels to make things go fast for my needs.
>> 
>> Despite the title of this thread there is no virtualization 
>> or emulation of the hardware involved.  Just enhancements to 
>> the existing hardware abstractions.
>
> Right, I was just trying to say that IOV support (likely, from multiple
> vendors since
> virtualization is expected to be widely used) would provide an option to
> export multiple
> independent L2 interfaces from a single NIC - even if only a subset of 
> IOV functionality would be used in this case.

Agreed, and I think I understood that.  My basic point was that it
doesn't look to me like I need the hardware support, just that I can
use it when it is there.

The core advantage I see of the multiple queues, is in being able to
split the processing of network traffic and interrupts among multiple
cores.

Eric
