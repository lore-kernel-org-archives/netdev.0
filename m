From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe:  schedule while atomic bug during dev_disable_lro 	2.6.31-rc3
Date: Thu, 16 Jul 2009 10:39:28 -0700
Message-ID: <4A5F65D0.9080202@candelatech.com>
References: <4A5E5F8A.308@candelatech.com> <1247700919.2788.11.camel@achroite> <4A5E6B37.2080605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39879 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932520AbZGPRjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 13:39:31 -0400
In-Reply-To: <4A5E6B37.2080605@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2009 04:50 PM, Ben Greear wrote:
> On 07/15/2009 04:35 PM, Ben Hutchings wrote:
>> On Wed, 2009-07-15 at 16:00 -0700, Ben Greear wrote:
>>> I just got a fancy new 10G NIC and tried it out in a (patched
>>> elsewhere, but stock ixgbe driver) 2.6.31-rc3) kernel.
>>
>> And what exactly are those patches?
>
> various and sundry, but so far I only see this problem with ixgbe
> (the 1G NICs don't complain at least).
>
> I'll build an un-patched kernel and see if I can reproduce them.

I see the same problem on a stock kernel.  I'm running a pre-empt kernel..think
that might have some bearing on the problem?

Full dmesg here:
http://www.candelatech.com/oss/i7_dmesg.txt

Kernel config file here:
http://www.candelatech.com/oss/i7_config.txt

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

