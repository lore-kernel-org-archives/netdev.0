From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/3] brcmfmac: dhd_sdio.c: use existing atomic_or primitive
Date: Mon, 27 Jul 2015 13:08:43 +0300
Message-ID: <871tftc3pw.fsf@kamboji.qca.qualcomm.com>
References: <1436429599-10762-1-git-send-email-vgupta@synopsys.com>
	<1436429599-10762-3-git-send-email-vgupta@synopsys.com>
	<87twstbi9p.fsf@kamboji.qca.qualcomm.com>
	<55B2743F.6060304@synopsys.com> <55B4C0A8.9000909@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vineet Gupta <vgupta@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arch@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky \(Zhenhui\) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B4C0A8.9000909@broadcom.com> (Arend van Spriel's message of
	"Sun, 26 Jul 2015 13:12:40 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend van Spriel <arend@broadcom.com> writes:

> On 07/24/2015 07:22 PM, Vineet Gupta wrote:
>> On Friday 24 July 2015 08:02 PM, Kalle Valo wrote:
>>> Vineet Gupta <Vineet.Gupta1@synopsys.com> writes:
>>>
>>>>> There's already a generic implementation so use that instead.
>>>>> ---
>>>>> I'm not sure if the driver usage of atomic_or?() is correct in terms of
>>>>> storage size of @val for 64 bit arches.
>>>>>
>>>>> Assuming LP64 programming model for linux on say x86_64: atomic_or()
>>>>> callers in this driver use long (sana 64 bit) storage and pass it to
>>>>> atomic_orr/atomic_or which downcasts it to 32 bits. Is that OK ?
>>>>> ---
>>>>> Cc: Brett Rudley <brudley@broadcom.com>
>>>>> Cc: Arend van Spriel <arend@broadcom.com>
>>>>> Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
>>>>> Cc: Hante Meuleman <meuleman@broadcom.com>
>>>>> Cc: Kalle Valo <kvalo@codeaurora.org>
>>>>> Cc: Pieter-Paul Giesberts <pieterpg@broadcom.com>
>>>>> Cc: Daniel Kim <dekim@broadcom.com>
>>>>> Cc: linux-wireless@vger.kernel.org
>>>>> Cc: brcm80211-dev-list@broadcom.com
>>>>> Cc: Peter Zijlstra <peterz@infradead.org>
>>>>> Cc: Ingo Molnar <mingo@kernel.org>
>>>>> Cc: netdev@vger.kernel.org
>>>>> Cc: linux-arch@vger.kernel.org
>>>>> Cc: linux-kernel@vger.kernel.org
>>>>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>>>>>
>>>>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>>> What's the plan with this patch? Should I take it to my
>>> wireless-drivers-next tree or will someone else take it?
>>
>>
>> Per last discussion on this topic, Arend wanted to discuss abt this with Hante.
>> I'm not taking it anyways so feel free to pick it up if you want !
>
> Well, that was before your "timeline" clarification about the generic
> function. One what tree is this patch based?

Yeah, if this patch depends on another patch I need to know about it.
Otherwise I might break something when I apply this patch.

-- 
Kalle Valo
