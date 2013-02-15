From: Ben Greear <greearb@candelatech.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 11:27:57 -0800
Message-ID: <511E8C3D.5070603@candelatech.com>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>  <511E8760.9070703@candelatech.com> <1360955900.19353.22.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49785 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3BOT2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 14:28:07 -0500
In-Reply-To: <1360955900.19353.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2013 11:18 AM, Eric Dumazet wrote:
> On Fri, 2013-02-15 at 11:07 -0800, Ben Greear wrote:
>
>> This has been around for a long time, maybe forever.  Last time
>> we looked at this it did not appear there was an easy fix, something
>> to do with how UDP packets are re-assembled....
>
> This can be fixed the same way we did for IPv4

For some reason I was thinking this wasn't fully fixed for IPv4, but
maybe it is..the bug in our internal tracker only mentions IPv6
as having issues...

We'll do some testing on IPv4 sometime soon to make sure, and can test
IPv6 patches as well...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
