From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: brcm80211 breakage..
Date: Fri, 13 Jan 2012 07:57:24 +0100
Message-ID: <CACna6rwUMMEWRVSKtJPavV7CUycYaMqphSuG_wvah5SO5QcA2A@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
	<4F0D6806.4080201@broadcom.com>
	<CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
	<CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
	<4F0DC030.6090500@lwfinger.net>
	<CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
	<4F0E3B7E.8040005@lwfinger.net>
	<CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
	<4F0E5E57.9060204@lwfinger.net>
	<CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
	<CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
	<CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
	<CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
	<CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
	<4F0F3DEC.4050605@broadcom.com>
	<CA+55aFw==r4TF5WPn5Ggz32m7yi2T71Ghdx+7ME=pEjQLqU=uw@mail.gmail.com>
	<CA+55aFxMh0T1W06YHepcPAyemcR4rrxghQeRKsW3MtT+gNK9eg@mail.gmail.com>
	<CACna6rwVTN6jQuAjVFN0p8QRVpt89ne7LxKbcmoorbZFtxFLkQ@mail.gmail.com>
	<CA+55aFz8z9V5vxBMAH3TFVmROj0C-8Mb+G0Ki=Yuai5_KG893A@mail.gmail.com>
	<CACna6rzeTmQu0c1=f6gizG_=XRkt3FdB7c_sAJtktjLdFmTQ3g@mail.gmail.com>
	<CA+55aFxZ7H=x2-rgQgRE9b=ky-h0WM1x-48Zs8a0dVt0NvkB_g@mail.gmail.com>
	<CA+55aFzP2NfDqiG9NCP+SyXstuNzJAVpN=KXTirhjhYzaCyPjA@mail.gmail.com>
	<CA+55aFx4Xuai3wS1Jk09mNeO7gVYqzTyX5ev_9oRxCyNdBrEaw@mail.gmail.com>
	<CACna6rwuyp+VY3ZveCv+HLuyfu0X27pxKAc=rdzrvY2BJPk8QQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45583 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab2AMG50 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 01:57:26 -0500
Received: by werb13 with SMTP id b13so135867wer.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 22:57:25 -0800 (PST)
In-Reply-To: <CACna6rwuyp+VY3ZveCv+HLuyfu0X27pxKAc=rdzrvY2BJPk8QQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 13 stycznia 2012 07:50 u=C5=BCytkownik Rafa=C5=82 Mi=C5=82ecki
<zajec5@gmail.com> napisa=C5=82:
> W dniu 13 stycznia 2012 06:34 u=C5=BCytkownik Linus Torvalds
> <torvalds@linux-foundation.org> napisa=C5=82:
>> 2012/1/12 Linus Torvalds <torvalds@linux-foundation.org>:
>>> 2012/1/12 Linus Torvalds <torvalds@linux-foundation.org>:
>>>>
>>>> I'm surprised it has ever worked for anybody. It certainly doesn't=
 work for me.
>>>
>>> So I can suspend the bcma driver on its own until the cows come hom=
e.
>>>
>>> But after I have suspended the bcma driver even once, just doing a
>>> "modprobe brcmsmac" will hang the machine hard. Dunno where, but th=
is
>>> is probably the same thing as "hangs on resume".
>>
>> Guys, has suspend/resume with the bcma interface been tested AT ALL?
>>
>> The suspend/resume fields of "struct bcma_driver" are COMPLETELY
>> UNUSED. The only place in the kernel that uses them is the brcmsmac
>> driver that does this write-only assignment:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.suspend =C2=A0=3D brcms_suspend,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.resume =C2=A0 =3D brcms_resume,
>>
>> nothing else uses them. NOTHING. I tested by just removing the field=
s
>> and compiling the bcma subsystem, just in case there was something
>> really subtle that I was missing and was hidden through some magic
>> hidden approach. But no.
>>
>> Seriously - how was something that isn't even connected ever suppose=
d
>> to work at all? And why was the BCMA conversion of that driver sent
>> up-stream if something as fundamental as suspend/resume had never be=
en
>> done, and didn't actually work?
>>
>> What am I missing now? How the hell can this ever have worked for
>> ANYBODY? What kind of f*&*ing sick joke is this all?
>
> The suspend&resume wasn't implemented for some time because my PC
> doesn't s&r. And I don't have access to notebook with mini PCIe slot.
>
> I've implemented support for s&r in bcma when I got to open my Sony
> VAIO to replace A/C power slot. It was one time I was able to change
> WiFi card in my notebook which has really-ugly-hidden mini PCIe slot.
>
> S&r was working fine for me with bcma&b43 after writing that patch!
> That includes suspending and resuming multiple times. And tests were
> done with the same card you're using.
>
> The lock up on (resume|loading brcmsmac) means bus wasn't initialized
> correctly after resume. It does not have to be brcmsmac bug. We're
> accessing some registers before they're ready.
>
> Linus: can you do one trivial test for me? Please simply try unloadin=
g
> bcma before suspending. Then resume and load bcma and brcmsmac. Does
> it still lockup your machine?

Actually.. I've re-read your mail and I got it wrong at first. I
though you can suspend&resume once, but then loading brcmsmac causes
lock up. I interpreted that as broken initialization after resume.

Now I see you *can't suspend for the second time*. I don't get it :/
I've no idea what wrong we may be doing in that trivial
bcma_host_pci_suspend and bcma_host_pci_resume stopping you from
suspending for the second time.

I'll take a look at that new pm ops you told me about.

--=20
Rafa=C5=82
