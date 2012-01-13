From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Fri, 13 Jan 2012 11:03:17 +0100
Message-ID: <CACna6rypt6ocF2ysyDMeCFsBXye24sTTEvRi63hiosUDVGS_RQ@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
	<1326440480-26271-1-git-send-email-zajec5@gmail.com>
	<alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
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
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39766 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096Ab2AMKDU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 05:03:20 -0500
Received: by wibhm14 with SMTP id hm14so223370wib.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 02:03:17 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 13 stycznia 2012 08:59 u=C5=BCytkownik Linus Torvalds
<torvalds@linux-foundation.org> napisa=C5=82:
>
> So here are five cleanup/fix patches that try to make the bcma and
> brcmsmac suspend/resume situation look better.
>
> The changes do:
>
> =C2=A0- use the modern PCI suspend/resume model, and let the PCI laye=
r handle
> =C2=A0 the actual standard power state changes.
>
> =C2=A0- clean up the BCMA suspend/resume infrastructure a bit in gene=
ral.
>
> =C2=A0- actually hook the BCMA suspend/resume callbacks up to the
> =C2=A0 suspend/resume event - it use to be that a bcma driver could s=
et its
> =C2=A0 suspend/resume routines, but nothing would ever call them.
>
> =C2=A0- and Rafa=C5=82's bcma window invalidation
>
> Comments? This gets suspend/resume working for me at least once. I'm =
not
> going to try to hang my machine again until after I have gotten this =
sent
> out.
>
> Does this work for others?

I have Asus netbook with BCM4313 since a week, so I'll able to test
this. Just give me a day when I'm back home.

Could we rearrange order of patches to make
bcma: invalidate the mapped window over suspend/resume
this first one and add stable as CC? What do you think about this?

--=20
Rafa=C5=82
