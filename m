From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v4] e1000: Support RX-ALL flag.
Date: Thu, 29 Mar 2012 18:56:50 -0700
Message-ID: <4F7512E2.9010502@candelatech.com>
References: <1333061270-4379-1-git-send-email-greearb@candelatech.com> <1333068960.2622.72.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36819 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758964Ab2C3B4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 21:56:52 -0400
In-Reply-To: <1333068960.2622.72.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2012 05:56 PM, Jeff Kirsher wrote:
> On Thu, 2012-03-29 at 15:47 -0700, greearb@candelatech.com wrote:
>>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This allows the NIC to receive errored frames (bad FCS, etc)
>> and pass them up the stack.  This can be useful when using
>> sniffers.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 a680ee6... ab2f748...
>> M  drivers/net/ethernet/intel/e1000/e1000_main.c
>>   drivers/net/ethernet/intel/e1000/e1000_main.c |   22
>> ++++++++++++++++++++--
>>   1 files changed, 20 insertions(+), 2 deletions(-)
>
> FYI- I was just about to push this upstream :)  Thanks Ben!
>
> This is the same patch Aaron has tested in-house.

Sounds good.

 From what I recall, igb is missing rx-fcs (and it may not be possible to
support the feature..chipset seems to act weird), but I think that takes care
of the rest of the 10/100/1000 Intel NICs.

I'll see if I can add some support for ixgbe when I get a chance.  That would
take care of all the NICs I normally use I think...


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
