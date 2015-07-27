From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 2/3] brcmfmac: dhd_sdio.c: use existing atomic_or
 primitive
Date: Mon, 27 Jul 2015 10:23:53 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075665AF526@IN01WEMBXB.internal.synopsys.com>
References: <1436429599-10762-1-git-send-email-vgupta@synopsys.com>
	<1436429599-10762-3-git-send-email-vgupta@synopsys.com>
	<87twstbi9p.fsf@kamboji.qca.qualcomm.com>	<55B2743F.6060304@synopsys.com>
 <55B4C0A8.9000909@broadcom.com> <871tftc3pw.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 July 2015 01:08 PM, Kalle Valo wrote:
>>> >> Per last discussion on this topic, Arend wanted to discuss abt this with Hante.
>>> >> I'm not taking it anyways so feel free to pick it up if you want !
>> >
>> > Well, that was before your "timeline" clarification about the generic
>> > function. One what tree is this patch based?
> Yeah, if this patch depends on another patch I need to know about it.
> Otherwise I might break something when I apply this patch.

It was latest linux-next at the time, 4.1-rcx perhaps, don't remember exactly. But
it certainly doesn't depend on any new code  - the patch simply makes use of an
existing API vs. using a local hard coded version of same.

Give it a spin off your existing tree - shdn't be too difficult to test  I presume.

-Vineet
