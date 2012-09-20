From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 1/2] Added information about which firmware file is being requested.
Date: Thu, 20 Sep 2012 08:06:44 +0200
Message-ID: <CACna6rw_=GWx8eymg3hsGc4v7pDKFx8Wxrym7c5pQOdseXfUSw@mail.gmail.com>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
	<505A1206.4020606@msgid.tls.msk.ru>
	<CAOjsGA3BgzBn-YOEFYFs5HqLAh4_d46Juj1M-XYooqXeVtn9uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	=?UTF-8?Q?G=C3=A1bor_Stefanik?= <netrolller.3d@gmail.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
To: Jarl Friis <jarl@softace.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46400 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303Ab2ITGGp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 02:06:45 -0400
In-Reply-To: <CAOjsGA3BgzBn-YOEFYFs5HqLAh4_d46Juj1M-XYooqXeVtn9uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/19 Jarl Friis <jarl@softace.dk>:
> 2012/9/19 Michael Tokarev <mjt@tls.msk.ru>:
>> On 19.09.2012 15:18, Jarl Friis wrote:
>>
>>> +     b43info(ctx->dev->wl, "Requesting firmware file '%s'\n", ctx-=
>fwname);
>>>       err =3D request_firmware(&blob, ctx->fwname, ctx->dev->dev->d=
ev);
>>
>> Hmm.  I wonder if this should be printed in request_firmware()
>> itself instead of in all callers?
>
> Now that you mention it, I also think that is a much better idea.
> However that would be a much more central place to do the change, so =
I
> would gladly see somebody else do that patch (in replacement of mine)

I agree, please submit patch modifying request_firmware if you believe
it's important.

--=20
Rafa=C5=82
