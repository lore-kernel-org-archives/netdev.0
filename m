From: Vineet Gupta <vgupta@synopsys.com>
Subject: Re: [PATCH 2/3] brcmfmac: dhd_sdio.c: use existing atomic_or primitive
Date: Fri, 24 Jul 2015 20:22:07 +0300
Message-ID: <55B2743F.6060304@synopsys.com>
References: <1436429599-10762-1-git-send-email-vgupta@synopsys.com>	<1436429599-10762-3-git-send-email-vgupta@synopsys.com> <87twstbi9p.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
	linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:36031 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbbGXRWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 13:22:13 -0400
In-Reply-To: <87twstbi9p.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 24 July 2015 08:02 PM, Kalle Valo wrote:
> Vineet Gupta <Vineet.Gupta1@synopsys.com> writes:
> 
>> > There's already a generic implementation so use that instead.
>> > ---
>> > I'm not sure if the driver usage of atomic_or?() is correct in terms of
>> > storage size of @val for 64 bit arches.
>> >
>> > Assuming LP64 programming model for linux on say x86_64: atomic_or()
>> > callers in this driver use long (sana 64 bit) storage and pass it to
>> > atomic_orr/atomic_or which downcasts it to 32 bits. Is that OK ?
>> > ---
>> > Cc: Brett Rudley <brudley@broadcom.com>
>> > Cc: Arend van Spriel <arend@broadcom.com>
>> > Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
>> > Cc: Hante Meuleman <meuleman@broadcom.com>
>> > Cc: Kalle Valo <kvalo@codeaurora.org>
>> > Cc: Pieter-Paul Giesberts <pieterpg@broadcom.com>
>> > Cc: Daniel Kim <dekim@broadcom.com>
>> > Cc: linux-wireless@vger.kernel.org
>> > Cc: brcm80211-dev-list@broadcom.com
>> > Cc: Peter Zijlstra <peterz@infradead.org>
>> > Cc: Ingo Molnar <mingo@kernel.org>
>> > Cc: netdev@vger.kernel.org
>> > Cc: linux-arch@vger.kernel.org
>> > Cc: linux-kernel@vger.kernel.org
>> > Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>> >
>> > Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
> What's the plan with this patch? Should I take it to my
> wireless-drivers-next tree or will someone else take it?


Per last discussion on this topic, Arend wanted to discuss abt this with Hante.
I'm not taking it anyways so feel free to pick it up if you want !

-Vineet
