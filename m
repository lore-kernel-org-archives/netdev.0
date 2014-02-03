From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 03 Feb 2014 14:06:55 -0800
Message-ID: <52F012FF.9030105@candelatech.com>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59366 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbaBCWGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 17:06:55 -0500
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id s13M6txQ004537
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Feb 2014 14:06:55 -0800
In-Reply-To: <20140203220323.GB17999@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2014 02:03 PM, Hannes Frederic Sowa wrote:
> Hi Ben,
> 
> On Mon, Feb 03, 2014 at 12:37:52PM -0800, Ben Greear wrote:
>> The kernel has some additional patches, but not much to IPv6.
>>
>> The bug is that when we have lots of mac-vlans on some ixgbe ports
>> (500 per interface in this case), and boot up the system with the ports unplugged,
>> we get this crash almost every time.  Boot-up is going to do normal bootup
>> stuff plus create and configure the 1000 mac-vlans, dump their routing
>> tables, etc.
>>
>> We are using one routing table per network device, and some
>> ip rules.
>>
>> If we plug in the ixgbe ports, we do not ever see a crash.
>>
>> We have not yet tried reproducing it on other drivers, but I suspect
>> the issue is not related to ixgbe.
>>
>> Any ideas on this one?
> 
> Could you bring the machine to a panic again with enabling RT6_DEBUG at the
> top of ip6_fib.c and send a dump of the trace?

Yes, but it will be a bit until we can create a duplicate machine.
We ended up delivering the machine with a note to make sure the
interfaces were plugged in (we found the bug hours before shipping
the system, of course).

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
