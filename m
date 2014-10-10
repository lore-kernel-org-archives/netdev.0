From: Thierry Herbelot <thierry.herbelot@6wind.com>
Subject: Re: [PATCH v2] ixgbe: check adapter->vfinfo before dereference
Date: Fri, 10 Oct 2014 10:53:18 +0200
Message-ID: <54379E7E.9070103@6wind.com>
References: <1412930732-892-1-git-send-email-thierry.herbelot@6wind.com> <1412931052.2427.33.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:40042 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaJJIxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 04:53:21 -0400
Received: by mail-wg0-f43.google.com with SMTP id m15so3355779wgh.14
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 01:53:20 -0700 (PDT)
In-Reply-To: <1412931052.2427.33.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 10:50 AM, Jeff Kirsher wrote:
> On Fri, 2014-10-10 at 10:45 +0200, Thierry Herbelot wrote:
>> this protects against the following panic:
>> (before a VF was actually created on p96p1 PF Ethernet port)
>> ip link set p96p1 vf 0 spoofchk off
>> BUG: unable to handle kernel NULL pointer dereference at
>> 0000000000000052
>> IP: [<ffffffffa044a1c1>] ixgbe_ndo_set_vf_spoofchk+0x51/0x150 [ixgbe]
>>
>> Signed-off-by: Thierry Herbelot <thierry.herbelot@6wind.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   73
>> +++++++++++++++++++++++-
>>   1 file changed, 70 insertions(+), 3 deletions(-)
>
> Thanks for fixing that up Thierry.  I have added your patch to my queue.

Sorry for the miscompile : I wrote the patch back in August, and left it 
to rot while doing other things and I did not check it was really 
correct before sending it yesterday.

	Thierry

>


-- 
Thierry Herbelot
6WIND
Software Engineer
