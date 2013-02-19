From: Ben Greear <greearb@candelatech.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Tue, 19 Feb 2013 14:37:53 -0800
Message-ID: <5123FEC1.7050608@candelatech.com>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>   <511E8760.9070703@candelatech.com>  <1360955900.19353.22.camel@edumazet-glaptop>  <511E8C3D.5070603@candelatech.com> <1360956930.19353.24.camel@edumazet-glaptop> <5123FB32.7050101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41704 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933223Ab3BSWiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:38:03 -0500
In-Reply-To: <5123FB32.7050101@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 02:22 PM, Ben Greear wrote:
> On 02/15/2013 11:35 AM, Eric Dumazet wrote:
>> On Fri, 2013-02-15 at 11:27 -0800, Ben Greear wrote:
>>
>>> For some reason I was thinking this wasn't fully fixed for IPv4, but
>>> maybe it is..the bug in our internal tracker only mentions IPv6
>>> as having issues...
>>>
>>> We'll do some testing on IPv4 sometime soon to make sure, and can test
>>> IPv6 patches as well...
>>
>> This worries me a bit, as I wrote this patch because you reported the
>> issue.
>
> We just did some testing on this on the 3.7.6+ kernel.  IPv4 multicast to
> mac-vlans works OK with large packets if there is a single multicast receiver,
> but does NOT work if there are multiple multicast receivers (ie, several
> mac-vlans with an mcast receive bound to each mvlan).

I should clarify this a bit:  This kernel has some additional
patches...probably nothing that makes this issue worse, but
I guess you never know.  We have not tested this on standard
upstream kernels.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
