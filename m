From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup
 behavior for VLAN interfaces
Date: Tue, 01 Aug 2006 10:04:24 -0700
Message-ID: <44CF8998.3000408@candelatech.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2> <20060801120836.GA29208@tuxdriver.com> <1154435614.5170.111.camel@jzny2> <44CF7CDE.4080601@candelatech.com> <20060801165218.GF29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Christophe Devriese <Christophe.Devriese@eurid.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:38813 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750866AbWHARFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 13:05:08 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801165218.GF29208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Tue, Aug 01, 2006 at 09:10:06AM -0700, Ben Greear wrote:
> 
>>Jamal Hadi Salim wrote:
> 
> 
>>>Agreed. I have some very strong opinions on this subject that i could
>>>share with you if you want. For example, IMO, I think it would be a lot
>>>reasonable to assume that a VLAN or VLANS are attributes of a netdevice
>>>(just like IP addresses or MAC addresses are). 
>>
>>As might be expected, I feel that VLANs are much more
>>useful as full-featured net devices.  I do not believe it is worth
>>decreasing functionality to try to 'clean up' the code.
> 
> 
> In general, I agree that we shouldn't lose functionality.
> 
> I'm curious as to what particularly functionality you fear would be
> lost if VLANs were not implemented the way they are now?

Well, Jamal and I and others discussed this in depth in the 2.4.12 time frame
when VLANs where about to go into the kernel.  Basically, my point is that
if VLANs are true devices, they will just work with all of the user-space protocols
and they will easily handle abstractions such as bridges, (multiple) IP addresses, MAC addresses,
net-filter, and all the rest.

Sounds like Jamal still remembers his reasons for wanting it otherwise...so
will let him describe his reasons.

Nothing is set in stone in Linux, and I am certainly not the final arbiter of
what gets into the linux kernel, but in my opinion, the current VLAN architecture
is supperior to the ip-alias model, and I see no reason to make any significant
changes.

Ben

> 
> Thanks,
> 
> John


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

