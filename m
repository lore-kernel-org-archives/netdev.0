From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 08:10:42 +0100
Message-ID: <CACna6rwj-hO5GzaxPb16VqGJ=G_2L9NFuphKtgmY+USNtGSn3g@mail.gmail.com>
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
	<CACna6rzv6iFiGP5F2mMs+2wxh0rVpXcXyBjve2Nbn9Ybp8AFsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36607 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab2ALHKn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 02:10:43 -0500
Received: by wibhm14 with SMTP id hm14so967334wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 23:10:42 -0800 (PST)
In-Reply-To: <CACna6rzv6iFiGP5F2mMs+2wxh0rVpXcXyBjve2Nbn9Ybp8AFsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 stycznia 2012 08:08 u=C5=BCytkownik Rafa=C5=82 Mi=C5=82ecki
<zajec5@gmail.com> napisa=C5=82:
> Linus: is this possible for you to give b43 a chance? It has to be co=
mpiled with
> B43_BCMA
> B43_PHY_N
> Unfortunately you have to install firmware manually to get b43 workin=
g
> :( Howto is located at:
> http://wireless.kernel.org/en/users/Drivers/b43
> ("Install b43-fwcutter" and "If you are using the b43 driver from 3.2
> kernel or newer:").
>
> b43 doesn't re-init bus devices, so this test will check if bcma is O=
K or not.

That probably will require blacklisting brcmsmac for a moment to
prevent bcma auto-loading it. Testing from cold-boot is recommended.

--=20
Rafa=C5=82
