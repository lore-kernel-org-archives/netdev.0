From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/5] send-crc: Add framework to allow sending packets
 with customized CRC.
Date: Wed, 08 Feb 2012 07:55:30 -0800
Message-ID: <4F329AF2.3010202@candelatech.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com> <4F322C2C.1010708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <tarbal@gmail.com>, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51818 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157Ab2BHPzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 10:55:36 -0500
In-Reply-To: <4F322C2C.1010708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2012 12:02 AM, Jeff Kirsher wrote:
> On 02/07/2012 11:49 AM, greearb@candelatech.com wrote:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This is useful for testing RX handling of frames with bad
>> CRCs.
>>
>> Requires driver support to actually put the packet on the
>> wire properly.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
> Ben-
>
> I tried to apply this series to Dave's net-next tree and I stopped after
> the first two patches did not apply cleanly.
>
> What tree did you use to generate this patch series?

I was using net-next from a few days ago...I'll rebase later today to
make sure everything is up to date and re-post.

Oh, that set is on top of the first two patches that enable rx-crc
infrastructure and e100 support..that might be the issue.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
