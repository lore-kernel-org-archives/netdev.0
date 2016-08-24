From: Xander Huff <xander.huff@ni.com>
Subject: Re: [PATCH] phy: request shared IRQ
Date: Wed, 24 Aug 2016 16:15:19 -0500
Message-ID: <57BE0E67.8060700@ni.com>
References: <1472061216-11111-1-git-send-email-xander.huff@ni.com> <e2248086-6087-0fcd-1338-8f6463943c62@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        brad.mouring@ni.com, Nathan Sullivan <nathan.sullivan@ni.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e2248086-6087-0fcd-1338-8f6463943c62@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/24/2016 1:41 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 08/24/2016 08:53 PM, Xander Huff wrote:
>
>> From: Nathan Sullivan <nathan.sullivan@ni.com>
>>
>> On hardware with multiple PHY devices hooked up to the same IRQ line, allow
>> them to share it.
>
>     Note that it had been allowed until my (erroneous?) commit
> 33c133cc7598e60976a069344910d63e56cc4401 ("phy: IRQ cannot be shared"), so I'd
> like this commit just reverted instead...
>     I'm not sure now what was the reason I concluded that the IRQ sharing was
> impossible... most probably I thought that the kernel IRQ handling code exited
> the loop over the IRQ actions once IRQ_HANDLED was returned -- which is
> obviously not so in reality...
>
> MBR, Sergei
>
Thanks for the suggestion, Sergei. I'll do just that.

-- 
Xander Huff
Staff Software Engineer
National Instruments
