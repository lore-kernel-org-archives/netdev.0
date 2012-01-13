From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 23:17:00 -0800
Message-ID: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
 <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
 <4F0F3DEC.4050605@broadcom.com> <CA+55aFw==r4TF5WPn5Ggz32m7yi2T71Ghdx+7ME=pEjQLqU=uw@mail.gmail.com>
 <CA+55aFxMh0T1W06YHepcPAyemcR4rrxghQeRKsW3MtT+gNK9eg@mail.gmail.com>
 <CACna6rwVTN6jQuAjVFN0p8QRVpt89ne7LxKbcmoorbZFtxFLkQ@mail.gmail.com>
 <CA+55aFz8z9V5vxBMAH3TFVmROj0C-8Mb+G0Ki=Yuai5_KG893A@mail.gmail.com>
 <CACna6rzeTmQu0c1=f6gizG_=XRkt3FdB7c_sAJtktjLdFmTQ3g@mail.gmail.com>
 <CA+55aFxZ7H=x2-rgQgRE9b=ky-h0WM1x-48Zs8a0dVt0NvkB_g@mail.gmail.com>
 <CA+55aFzP2NfDqiG9NCP+SyXstuNzJAVpN=KXTirhjhYzaCyPjA@mail.gmail.com>
 <CA+55aFx4Xuai3wS1Jk09mNeO7gVYqzTyX5ev_9oRxCyNdBrEaw@mail.gmail.com>
 <CACna6rwuyp+VY3ZveCv+HLuyfu0X27pxKAc=rdzrvY2BJPk8QQ@mail.gmail.com> <CACna6rwUMMEWRVSKtJPavV7CUycYaMqphSuG_wvah5SO5QcA2A@mail.gmail.com>
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
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51189 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab2AMHRb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:17:31 -0500
Received: by yhnn56 with SMTP id n56so122024yhn.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:17:30 -0800 (PST)
In-Reply-To: <CACna6rwUMMEWRVSKtJPavV7CUycYaMqphSuG_wvah5SO5QcA2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/12 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>
> Actually.. I've re-read your mail and I got it wrong at first. I
> though you can suspend&resume once, but then loading brcmsmac causes
> lock up. I interpreted that as broken initialization after resume.

That is correct.

And I cannot suspend/resume AT ALL if I actually keep brcmsmac loaded
- then it will lock up at resume - exactly the same way it locks up at
loading brcmsmac time if I had unloaded it.

> Now I see you *can't suspend for the second time*. I don't get it :/

No, that was an unrelated bug, I'm chasing that one down too and it
seems to be in the machine check driver.

                           Linus
