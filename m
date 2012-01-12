From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 16:46:24 +0100
Message-ID: <CACna6rwtC4pBQu8i=beBpdn8W-Cc4nMY7TB1s2Rwnqv7TG0YwA@mail.gmail.com>
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
	<4F0EFEA1.9000907@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38858 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061Ab2ALPq0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 10:46:26 -0500
Received: by werm1 with SMTP id m1so1442959wer.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 07:46:25 -0800 (PST)
In-Reply-To: <4F0EFEA1.9000907@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 stycznia 2012 16:39 u=C5=BCytkownik Larry Finger
<Larry.Finger@lwfinger.net> napisa=C5=82:
> On 01/12/2012 01:08 AM, Rafa=C5=82 Mi=C5=82ecki wrote:
>>
>> 2012/1/12 Linus Torvalds<torvalds@linux-foundation.org>:
>>>
>>> On Wed, Jan 11, 2012 at 9:20 PM, Linus Torvalds
>>> <torvalds@linux-foundation.org> =C2=A0wrote:
>>>>
>>>>
>>>> Maybe your BIOS firmware sets things up, and the Apple Macbook Air
>>>> doesn't? And the driver used to initialize things sufficiently, an=
d
>>>> the changes have broken that?
>>>
>>>
>>> The code in v3.2 also used to support srom rev< =C2=A04, the new co=
de
>>> doesn't seem to do that.
>>
>>
>> After hacking bcma to read SPROM from the correct location, what did
>> you get in dmesg? There should be info about version of SPROM.
>
>
> In the bcma version of the SPROM reading, there is no error logging o=
ther
> than the incorrect version message. In particular, there is no messag=
e when
> the CRC test fails, and the version will not be logged.

Oops, you're right. I forgot bcma doesn't have that (on the difference =
to ssb).

--=20
Rafa=C5=82
