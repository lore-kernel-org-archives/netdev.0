From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: mwifiex: propagate error if IRQ request fails in
 mwifiex_sdio_of()
Date: Tue, 6 Sep 2016 14:12:33 +0200
Message-ID: <66735eb5-c831-8e06-337b-80ccfc392061@osg.samsung.com>
References: <20160903103520.8C69C6201B@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        Amitkumar Karwar <akarwar@marvell.com>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160903103520.8C69C6201B@smtp.codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Kalle,

On 09/03/2016 12:35 PM, Kalle Valo wrote:
> Javier Martinez Canillas <javier@osg.samsung.com> wrote:
>> If request_irq() fails in mwifiex_sdio_probe_of(), only an error message
>> is printed but the actual error is not propagated to the caller function.
>>
>> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> 
> What's the conclusion with this patch? Should I drop it or take it?
> 
> (The discussion is available from the patchwork link in the signature.)
> 

My understanding is that Arend agrees with the patch and that the question
raised was caused by looking at an older kernel version. IOW, the patch is
OK and should be picked.

I'm adding Arend to cc, so can comment in case I misunderstood him though.

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
