From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4/IPv6: update sysctl files
Date: Wed, 08 Apr 2009 00:18:28 -0700 (PDT)
Message-ID: <20090408.001828.262566823.davem@davemloft.net>
References: <49DC091C.6070708@cn.fujitsu.com>
	<1239158863.11534.52.camel@deadeye.i.decadent.org.uk>
	<49DC19D5.7090101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754600AbZDHHSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 03:18:38 -0400
In-Reply-To: <49DC19D5.7090101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shen Feng <shen@cn.fujitsu.com>
Date: Wed, 08 Apr 2009 11:28:21 +0800

> 
> 
> on 04/08/2009 10:47 AM, Ben Hutchings wrote:
>> On Wed, 2009-04-08 at 02:39 +0000, Shen Feng wrote:
>>> Now the following sysctl files in /proc/sys/net/ipv4 are used by
>>> both IPv4 and IPv6.
>>> tcp_mem  tcp_rmem  tcp_wmem
>>> udp_mem  udp_rmem_min  udp_wmem_min
>>> Putting them in /proc/sys/net/ipv4 is not a good choice.
>> [...]
>> 
>> But this is part of the ABI to userland.  You cannot remove sysctl files
>> without long advance notice documented in feature-removal-schedule.txt
>> (if at all).
>> 
>> If it is possible to add the paths
>> /proc/sys/net/{tcp,udp} while retaining aliases under /proc/sys/net/ipv4
>> then that might be a workable solution.
> 
> Thanks. That's a good solution.
> 
> But I'm still confused.
> Why not create another tcp_mem in /proc/sys/net/ipv6?

People just need to understand that ipv4 is always going to be
there and that's where all the tcp controls are.

I really am not going to entertain changes that try to move generic
inet sysctl things out of the ipv4 directory.  There is really no
point at all.

