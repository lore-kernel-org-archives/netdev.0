From: Ben Greear <greearb@candelatech.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Wed, 23 Sep 2009 11:56:04 -0700
Message-ID: <4ABA6F44.4000702@candelatech.com>
References: <4ABA4F8B.6040504@candelatech.com>	 <1253730766.2538.28.camel@localhost.localdomain>	 <4ABA6D0D.8010200@candelatech.com> <1253731834.2538.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57782 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbZIWS4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:56:01 -0400
In-Reply-To: <1253731834.2538.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2009 11:50 AM, Peter P Waskiewicz Jr wrote:

>> That's a bummer.  I'm guessing you might get close to right on average with some
>> trivial math, but if someone is sending you pkts with size of 1000 and
>> your MTU is 1500, would there be any way to tell that the pkts were originally
>> 1000 bytes instead of 1500?
>
> Good point.
>
>> Next time you guys re-compile your hardware, please consider adding byte counters :)
>
> On 10G adapters, byte counters can skyrocket quickly, so we'd need to
> read them often to avoid them wrapping.  But I will forward your request
> to our HW design folks and see if they have other ideas to implement
> these counters and make them efficient.

It still takes a while to wrap 64-bit counters :)

But, you do have to read every 3 secs or so if you're using 32-bit counters.

This can be dealt with in user-space easily enough as long as polling
the NIC for counters is efficient.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

