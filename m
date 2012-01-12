From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: brcm80211 breakage..
Date: Fri, 13 Jan 2012 00:04:04 +0100
Message-ID: <CACna6rzeTmQu0c1=f6gizG_=XRkt3FdB7c_sAJtktjLdFmTQ3g@mail.gmail.com>
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
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48264 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab2ALXEF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 18:04:05 -0500
Received: by wgbdt14 with SMTP id dt14so771577wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 15:04:04 -0800 (PST)
In-Reply-To: <CA+55aFz8z9V5vxBMAH3TFVmROj0C-8Mb+G0Ki=Yuai5_KG893A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 stycznia 2012 23:45 u=C5=BCytkownik Linus Torvalds
<torvalds@linux-foundation.org> napisa=C5=82:
> 2012/1/12 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>>
>> Make sure you have
>>
>> commit 775ab52142b02237a54184238e922251c59a2b5c
>> Author: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>> Date: =C2=A0 Fri Dec 9 22:16:07 2011 +0100
>>
>> =C2=A0 =C2=A0bcma: support for suspend and resume
>>
>> applied. I believe this patch already has hit your tree, but maybe
>> because of bisecting you are at some old commit without this patch.
>
> That one is *not* sufficient. Current -git doesn't suspend/resume.

=46orgive me if it was already said, but I didn't see it.

Have you tried booting with bcma & brcmsmac blacklisted? Does
suspend&resume work then?

Have you tried blacklisting just brcmsmac (letting bcma load)? Does
s&r work then?

--=20
Rafa=C5=82
