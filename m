From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 4.7 FIX] brcmfmac: fix lockup when removing P2P interface after event timeout
Date: Fri, 17 Jun 2016 12:49:19 +0300
Message-ID: <87h9csuov4.fsf@kamboji.qca.qualcomm.com>
References: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
	<877fdpw4no.fsf@kamboji.qca.qualcomm.com>
	<CACna6rzXzj4DJNA6855Qy6QnxETnYEPmqtw3Bcx8WWCtYwYvuw@mail.gmail.com>
	<87lh24v1n6.fsf@kamboji.qca.qualcomm.com>
	<CACna6rym3y0sqAUptgnt-mUiBidFGzVAzw4XcYr95q6MD2r5yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky \(Zhenhui\) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	brcm80211 development <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACna6rym3y0sqAUptgnt-mUiBidFGzVAzw4XcYr95q6MD2r5yw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(=?utf-8?Q?=22Rafa=C5=82_Mi=C5=82ecki=22's?= message of "Fri, 17 Jun 2016
 07:33:20 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

>>>> Failed to apply, please rebase:
>>>>
>>>> Applying: brcmfmac: fix lockup when removing P2P interface after e=
vent timeout
>>>> Using index info to reconstruct a base tree...
>>>> Falling back to patching base and 3-way merge...
>>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.=
c
>>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/core=
=2Eh
>>>> CONFLICT (content): Merge conflict in drivers/net/wireless/broadco=
m/brcm80211/brcmfmac/core.h
>>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/core=
=2Ec
>>>> Auto-merging drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg8=
0211.c
>>>> Failed to merge in the changes.
>>>> Patch failed at 0001 brcmfmac: fix lockup when removing P2P interf=
ace after event timeout
>>>
>>> What tree did you try it on?
>>>
>>> I just went into a dir where I have cloned:
>>> git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-driver=
s.git
>>>
>>> My HEAD commit is:
>>> 034fdd4 Merge ath-current from ath.git
>>>
>>> And I can apply this patch cleanly doing:
>>> curl https://patchwork.kernel.org/patch/9138925/mbox/ | git am
>>
>> I was trying to apply this to wireless-drivers-next. I didn't get a
>> confirmation from Arend and I didn't consider the fix important enou=
gh
>> for 4.7. But of course I can reconsider if needed.
>
> I think I agree it won't hurt to get it into -next. Noone earlier
> reported this bug and it seems to be there for a long time. Also
> applying it to -next will allow avoiding merge conflicts and immediat=
e
> development work on -next.

Exactly, there is a cost when taking patches to wireless-drivers.git an=
d
that's why I try to keep the bar high. Regressions and user reported
bugs take priority, other fixes are handled case by case.

> I'll resend this patch rebased on -next soon.

Thanks.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
