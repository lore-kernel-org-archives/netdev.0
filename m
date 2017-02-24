From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [PATCH 3/3] mwifiex: wake system up when receives a wake irq
Date: Fri, 24 Feb 2017 20:20:55 +0800
Message-ID: <58B02527.6090400@rock-chips.com>
References: <1487917471-5501-1-git-send-email-jeffy.chen@rock-chips.com> <1487917471-5501-3-git-send-email-jeffy.chen@rock-chips.com> <87d1e726p5.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Brian Norris <briannorris@chromium.org>,
        Rajat Jain <rajatja@google.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1e726p5.fsf@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kalle,

On 02/24/2017 07:01 PM, Kalle Valo wrote:
> Jeffy Chen <jeffy.chen@rock-chips.com> writes:
>
>> Currrently we are disabling this wake irq after receiving it. If this
>> happens before we finish suspend and the pm event check is disabled,
>> the system will continue suspending, and this irq would not work again.
>>
>> We may need to abort system suspend to avoid that.
>>
>> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
> I only see patch 3 in patchwork. Where are patches 1 and 2?
>


the other two are much like this one, but for bluetooth :)

please check:

https://patchwork.kernel.org/patch/9589455 New          [1/3] btusb: 
wake system up when receives a wake irq
https://patchwork.kernel.org/patch/9589453 New          [2/3] btmrvl: 
wake system up when receives a wake irq
https://patchwork.kernel.org/patch/9589457 New          [3/3] mwifiex: 
wake system up when receives a wake irq



(sorry, this is a resent mail, because the last one was rejected due to 
wrong format)
