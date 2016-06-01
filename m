From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 7/8] mwifiex: don't print an error if an optional DT
 property is missing
Date: Thu, 2 Jun 2016 09:13:35 +1000
Message-ID: <CAGRGNgUaNAxhhvnVJDx73yABvp3HXfqK5JFKCKvOgkM0DyFuPA@mail.gmail.com>
References: <1464358702-19083-1-git-send-email-javier@osg.samsung.com>
 <1464358702-19083-8-git-send-email-javier@osg.samsung.com>
 <CAGRGNgUZ+mG_KzhiOzquB3qd-V_Pdbazag=nrFpG87mRQGmXLg@mail.gmail.com> <ec09757e-302a-b341-6bf0-46737abb7976@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Nishant Sarmukadam <nishants@marvell.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>,
	Xinming Hu <huxm@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ec09757e-302a-b341-6bf0-46737abb7976@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Javier,

On Wed, Jun 1, 2016 at 11:51 PM, Javier Martinez Canillas
<javier@osg.samsung.com> wrote:
> Hello Julian,
>
> Thanks a lot for your feedback and reviews.
>
> On 06/01/2016 12:20 AM, Julian Calaby wrote:
>> Hi All,
>>
>> On Sat, May 28, 2016 at 12:18 AM, Javier Martinez Canillas
>> <javier@osg.samsung.com> wrote:
>>> The Documentation/devicetree/bindings/net/wireless/marvell-sd8xxx.txt DT
>>> binding document say that the "interrupts" property in the child node is
>>> optional. So the property being missed shouldn't be treated as an error.
>>
>> Have you checked whether it is truly optional? I.e. nothing else
>> breaks if this property isn't set?
>>
>
> That's what the DT binding says and the IRQ is only used as a wakeup source
> during system suspend, it is not used during runtime. And that is why the
> mwifiex_sdio_probe_of() function does not fail if the IRQ is missing.

Awesome, that's what I wanted to know.

> Now, I just got to that conclusion by reading the binding docs, the message
> in the commits that introduced this and the driver code. Xinming Hu should
> comment on how critical this feature is for systems that needs to be wakeup.

Xinming, could you review this also?

> In any case I think that the code should be consistent with what the binding
> doc says and also the function does (i.e: dev_err only if returns an error).
>
>>> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
>>
>> Other than that, this looks sensible to me.
>>
>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>>
>
> Best regards,

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
