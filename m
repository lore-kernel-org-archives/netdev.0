From: Shawn Lin <shawn.lin@rock-chips.com>
Subject: Re: [PATCH] mwifiex: fix compile warning of unused variable
Date: Thu, 6 Jul 2017 16:18:56 +0800
Message-ID: <5adbeb32-7510-d08e-9bb6-c18fd490388c@rock-chips.com>
References: <1499327433-70786-1-git-send-email-shawn.lin@rock-chips.com>
 <87k23mf15x.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shawn.lin@rock-chips.com, Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Xinming Hu <huxm@marvell.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.133]:55335 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdGFISz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 04:18:55 -0400
In-Reply-To: <87k23mf15x.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kalle,

On 2017/7/6 15:57, Kalle Valo wrote:
> Shawn Lin <shawn.lin@rock-chips.com> writes:
> 
>> We got a compile warning shows below:
>>
>> drivers/net/wireless/marvell/mwifiex/sdio.c: In function
>> 'mwifiex_sdio_remove':
>> drivers/net/wireless/marvell/mwifiex/sdio.c:377:6: warning: variable
>> 'ret' set but not used [-Wunused-but-set-variable]
>>
>> Per the code, it didn't check if mwifiex_sdio_read_fw_status
>> finish successfully. We should at least check the return of
>> mwifiex_sdio_read_fw_status, otherwise the following check of
>> firmware_stat and adapter->mfg_mode is pointless as the device
>> is probably dead.
> 
> I don't see that warning, any ideas why? My compiler:
> 
> gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609

I was using gcc-arm-eabi-4.8- , but it doesn't matter.

Could you add W=1 to compile the code, for instance, "make W=1  -j32"

> 
> 
