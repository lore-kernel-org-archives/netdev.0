From: Wei Shuai <cpuwolf@gmail.com>
Subject: Re: [PATCH 2/2] CDC_NCM: adding support FLAG_NOARP for Infineon modem platform
Date: Mon, 21 Jan 2013 16:22:47 +0800
Message-ID: <CACa7zyncby5Tdizx85CxoxirdGrO-ocshp43oNEyokLzZboX_A@mail.gmail.com>
References: <1358662329-8294-2-git-send-email-cpuwolf@gmail.com>
	<50FC25B7.70708@mvista.com>
	<CACa7zynymtYN4OtTjVNTNdB23eNU4D-G+JqaTxjaPFekRHkRAg@mail.gmail.com>
	<20130120.230902.1326170122198671921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: sshtylyov@mvista.com, dcbw@redhat.com, peter@stuge.se,
	oneukum@suse.de, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:50992 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab3AUIWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 03:22:48 -0500
In-Reply-To: <20130120.230902.1326170122198671921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you David. yes in the core driver, FLAG_NOARP will be translated
to IFF_NOARP

2013/1/21, David Miller <davem@davemloft.net>:
> From: Wei Shuai <cpuwolf@gmail.com>
> Date: Mon, 21 Jan 2013 10:20:22 +0800
>
>> The main problem is that these devices don't support ethernet.
>
> He's saying your comment is referring to the wrong thing,
> rather than saying anything against what your change is
> doing.
>
> Read his feedback carefully:
>
>>>> +/* Same as wwan_info, but with IFF_NOARP  */
>>>
>>>     FLAG_NOARP, you mean?
>
> He's saying your commnet is talking about FLAG_NOARP rather
> than what the core code does with this flag, which is
> translate into setting IFF_NOARP on the net device.
>
>
