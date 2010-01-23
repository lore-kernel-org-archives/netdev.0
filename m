From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] Fix IPv6 GSO type checks in Intel ethernet
	drivers
Date: Sat, 23 Jan 2010 01:31:08 -0800
Message-ID: <9929d2391001230131w1b23526r905dd6fe8b7d9209@mail.gmail.com>
References: <20100123092430.11188.13968.stgit@localhost.localdomain>
	 <20100123.012723.129767377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, gospo@redhat.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f182.google.com ([209.85.216.182]:58977 "EHLO
	mail-px0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab0AWJbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:31:09 -0500
Received: by pxi12 with SMTP id 12so1558342pxi.33
        for <netdev@vger.kernel.org>; Sat, 23 Jan 2010 01:31:08 -0800 (PST)
In-Reply-To: <20100123.012723.129767377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2010 at 01:27, David Miller <davem@davemloft.net> wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat, 23 Jan 2010 01:24:45 -0800
>
>> From: Sridhar Samudrala <sri@us.ibm.com>
>>
>> Found this problem when testing IPv6 from a KVM guest to a remote
>> host via e1000e device on the host.
>> The following patch fixes the check for IPv6 GSO packet in Intel
>> ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
>> when packets are forwarded from a guest.
>>
>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> This is definitely net-2.6 material, the bug definitely exists
> there and besides the ixgbevf bit, this patch applies cleanly
> to net-2.6 as well.
>
> Please spin two patches, one which gets everything in net-2.6
> and one which hits ixgbevf in net-next-2.6
>
> Thanks.
> --

Thanks Dave, I will work up the two patches now.

-- 
Cheers,
Jeff
