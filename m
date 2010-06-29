From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than
 10 times.
Date: Tue, 29 Jun 2010 09:30:57 -0700
Message-ID: <4C2A1FC1.9010403@candelatech.com>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com> <50mof7-b9p.ln1@chipmunk.wormnet.eu> <4C2A0B82.7020701@candelatech.com> <38hpf7-map.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34702 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab0F2QbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 12:31:08 -0400
In-Reply-To: <38hpf7-map.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2010 08:48 AM, Alexander Clouter wrote:
> Ben Greear<greearb@candelatech.com>  wrote:
>>
>>>> This is useful for getting rid of large numbers of IP
>>>> addresses in scripts.
>>>>
>>> Maybe I am missing a trick, but what is wrong with putting this trivial
>>> logic into the script:
>>>
>>> ip addr show ${DEV} | awk '/inet6? / { print $2 }' | xargs -I{} ip addr del '{}' dev ${DEV}
>>
>> This isn't going to be fast if you have thousands of addresses.
>>
> Obviously not like-for-like but:

You might try comparing against -batch mode v/s individual
calls to ip.

I'd enjoy adding/removing thousands of IP addrs in < 1 second,
but got a bit of work to do before I get there I think.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
