From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Wed, 23 Sep 2009 19:08:12 -0700
Message-ID: <4ABAD48C.9010808@candelatech.com>
References: <4ABAA2D0.4030608@candelatech.com> <4ABAB727.2020507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38965 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbZIXCIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 22:08:11 -0400
In-Reply-To: <4ABAB727.2020507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Ben Greear wrote:
>> When LRO is enabled, the received packet and byte counters represent the
>> LRO'd packets, not the packets/bytes on the wire. 
>
> When LRO is enabled, are all the bytes on the wire actually 
> transferred into the host?
No...the ethernet, IP and TCP headers and such are not, for packets that 
are combined into a single
large SKB.

That is why the driver counts them wrong.  The bytes are off by a few 
percentage points, but the
packet count is off by an order of magnitude.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


