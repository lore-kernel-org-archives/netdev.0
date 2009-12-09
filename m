From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe funkiness after OOM
Date: Tue, 08 Dec 2009 22:57:49 -0800
Message-ID: <4B1F4A6D.1000200@candelatech.com>
References: <4B1EEB86.4030903@candelatech.com> <1260341240.2239.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49071 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705AbZLIG5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 01:57:45 -0500
In-Reply-To: <1260341240.2239.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2009 10:47 PM, Peter P Waskiewicz Jr wrote:

>> At this point, there is 8GB of free RAM, and no obvious OOM issues showing up in the logs.
>>
>> It looks like error -12 means:
>>
>> IXGBE_ERR_MASTER_REQUESTS_PENDING
>>
>
> We have a fix coming for this issue.  Basically we have PCIe
> transactions that haven't completed when a reset shows up, and are
> wedged in the PCIe block.  We have a way to whack the hardware the right
> way to get these pending transactions cleared, which allows the device
> to finish its reset correctly.
>
> I'll try and get that patch fast-tracked through our testing.  But if
> this issue is easily reproducible for you, I can send you the patch in
> the meantime to see if it helps your situation, while we finish our test
> pass and push to netdev.

I've had several other NIC lockups that appear similar, but I didn't
look at them so closely.  I'd be happy to test a patch if you have
one handy.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
