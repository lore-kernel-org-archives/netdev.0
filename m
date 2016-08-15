From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [BUGFIX PATCH 1/2] brcmfmac: Check rtnl_lock is locked when
 removing interface
Date: Mon, 15 Aug 2016 23:44:05 +0200
Message-ID: <15e43df4-b8cc-8612-472e-80634cf27cac@broadcom.com>
References: <147125403645.9434.8008546579326856373.stgit@devbox>
 <147125405701.9434.12911635695339175773.stgit@devbox>
 <5bb6e373-e110-b1ac-6f65-fdf2f9f059fc@gmail.com>
 <87wpjib8pb.fsf@kamboji.qca.qualcomm.com>
 <CACna6ryuN_qDrVwAbS5P9mfhjMwv2hNeTqEzTQ=WxvP1V=zHXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Masami Hiramatsu <mhiramat@kernel.org>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
	<brcm80211-dev-list.pdl@broadcom.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6ryuN_qDrVwAbS5P9mfhjMwv2hNeTqEzTQ=WxvP1V=zHXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 15-8-2016 13:52, Rafał Miłecki wrote:
> On 15 August 2016 at 12:57, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Rafał Miłecki <zajec5@gmail.com> writes:
>>
>>>> Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
>>>
>>> Fixes: a63b09872c1d ("brcmfmac: delete interface directly in code that sent fw request")
>>> Acked-by: Rafał Miłecki <rafal@milecki.pl>
>>>
>>> Kalle: I'm acking this as bugfix for 4.8 release.
>>
>> Ok. I'll wait few days for more comments before I apply this.
> 
> Sure.
> 
> 
>> (I assume you are talking only about patch 1)
> 
> Yes, I'll leave mutex vs. spinlock to the experts :)

Don't know who the experts are. Surely not me :-p

I made an uneducated design decision using a mutex for this. The
reasoning for using a regular spinlock make sense. So I will go and ack
that patch.

Regards,
Arend
