From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Regression][v3.10][v3.11] net: Kill link between CSUM and SG features.
Date: Tue, 16 Jul 2013 13:50:47 -0700
Message-ID: <CALnjE+rhvmYPEXv=1F1HEe3VsgCNN1SKg5UwTuFatQUm9e9S2w@mail.gmail.com>
References: <51E58C45.1080708@canonical.com>
	<CALnjE+oCeo=T+F3BvTBtcV7oDMPLJAEz1p1sjRGxmE8Wq8gWAg@mail.gmail.com>
	<51E5A4CA.20902@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, ben.howard@canonical.com, edumazet@google.com,
	xiyou.wangcong@gmail.com, alexander.h.duyck@intel.com,
	jiri@resnulli.us, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, kys@microsoft.com,
	haiyangz@microsoft.com
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:58812 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933670Ab3GPUut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:50:49 -0400
Received: by mail-qc0-f181.google.com with SMTP id u12so663501qcx.40
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 13:50:48 -0700 (PDT)
In-Reply-To: <51E5A4CA.20902@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 12:53 PM, Joseph Salisbury
<joseph.salisbury@canonical.com> wrote:
> On 07/16/2013 02:29 PM, Pravin Shelar wrote:
>> On Tue, Jul 16, 2013 at 11:09 AM, Joseph Salisbury
>> <joseph.salisbury@canonical.com> wrote:
>>> Hi Pravin,
>>>
>>> A bug was opened against the Ubuntu kernel[0].  After a kernel bisect,
>>> it was found that reverting the following commit resolved this bug:
>>>
>>> commit ec5f061564238892005257c83565a0b58ec79295
>>> Author: Pravin B Shelar <pshelar@nicira.com>
>>> Date:   Thu Mar 7 09:28:01 2013 +0000
>>>
>>>     net: Kill link between CSUM and SG features.
>>>
>>>
>>> The regression was introduced as of v3.10-rc1.
>>>
>>> I see that you are the author of this patch, so I wanted to run this by
>>> you.  I was thinking of requesting a revert for v3.11, but I wanted to
>>> get your feedback first.
>>>
>>>
>> This issue was reported before and turning off sg solves problem for
>> HyperV driver. Drivers (intel and bnx2x) that I tested works fine with
>> this patch. Have you seen the issue on any other NIC?
>
> Thanks for the feedback.  We have only seen it on Intel hardware.  Can
> you send a pointer to the patch? If so, we can provide some additional
> testing.  Do you plan on submitting the patch for inclusion in 3.11?
>
>
What I mean is I do not see any problem with the patch that you have
pointed out on ixgbe and bnx2x platforms. HyperV problem went away
with disabling sg by ethtool utility.

Can you also give me more information about regression you are seeing
like driver name, features of the NIC set and features of device
without this patch. Does any other NIC than HyperV having this issue?

Thanks.

>>
>>
>>> Thanks,
>>>
>>> Joe
>>>
>>> [0] http://pad.lv/1200243
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
