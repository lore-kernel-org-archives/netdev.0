From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 08:18:15 +0100
Message-ID: <CACna6rzSx-h98z1Tf1W0maYKgA-3wjE3_oimcFCOcrnko7q8CQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Arend van Spriel <arend@broadcom.com>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:44475 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab2ALHSR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 02:18:17 -0500
Received: by wibhm14 with SMTP id hm14so970161wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 23:18:16 -0800 (PST)
In-Reply-To: <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/12 Linus Torvalds <torvalds@linux-foundation.org>:
> On Wed, Jan 11, 2012 at 9:30 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> The code in v3.2 also used to support srom rev < 4, the new code
>> doesn't seem to do that.
>
> I ended up trying to bisect this, and seem to have been successful.
> The problem came in not with the BCMA use, but with commit
> 888153b3db3f ("brcm80211: smac: avoid sprom endianess conversions for
> crc8 check")

Uh, OK, that was tricky. BCMA switch was the biggest change and we
were assuming it has to be the guilty one. Thanks for bisecting!

--=20
Rafa=C5=82
