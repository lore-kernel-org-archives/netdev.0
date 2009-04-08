From: Shen Feng <shen@cn.fujitsu.com>
Subject: Re: [PATCH] IPv4/IPv6: update sysctl files
Date: Wed, 08 Apr 2009 16:50:49 +0800
Message-ID: <49DC6569.5030908@cn.fujitsu.com>
References: <49DC091C.6070708@cn.fujitsu.com>	<1239158863.11534.52.camel@deadeye.i.decadent.org.uk>	<49DC19D5.7090101@cn.fujitsu.com> <20090408.001828.262566823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64747 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762169AbZDHIvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:51:44 -0400
In-Reply-To: <20090408.001828.262566823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



on 04/08/2009 03:18 PM, David Miller wrote:
> From: Shen Feng <shen@cn.fujitsu.com>
> Date: Wed, 08 Apr 2009 11:28:21 +0800
> 
>>
>> on 04/08/2009 10:47 AM, Ben Hutchings wrote:
>>> On Wed, 2009-04-08 at 02:39 +0000, Shen Feng wrote:
>>>> Now the following sysctl files in /proc/sys/net/ipv4 are used by
>>>> both IPv4 and IPv6.
>>>> tcp_mem  tcp_rmem  tcp_wmem
>>>> udp_mem  udp_rmem_min  udp_wmem_min
>>>> Putting them in /proc/sys/net/ipv4 is not a good choice.
>>> [...]
>>>
>>> But this is part of the ABI to userland.  You cannot remove sysctl files
>>> without long advance notice documented in feature-removal-schedule.txt
>>> (if at all).
>>>
>>> If it is possible to add the paths
>>> /proc/sys/net/{tcp,udp} while retaining aliases under /proc/sys/net/ipv4
>>> then that might be a workable solution.
>> Thanks. That's a good solution.
>>
>> But I'm still confused.
>> Why not create another tcp_mem in /proc/sys/net/ipv6?
> 
> People just need to understand that ipv4 is always going to be
> there and that's where all the tcp controls are.
> 
> I really am not going to entertain changes that try to move generic
> inet sysctl things out of the ipv4 directory.  There is really no
> point at all.
> 

/proc/sys/net/ipv4/tcp_mem is a inet sysctl, but it also controls the tcp v6.
So it's also a inet6 sysctl. Is it intentional?
This may confuse users. We may have a /proc/sys/net/ipv6/tcp6_mem.

> 
> 
