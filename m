From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] net: spread __net_init, __net_exit
Date: Sun, 17 Jan 2010 21:15:07 +0100
Message-ID: <e2d7436a1001171215m2270416fj83f40646f09507a8@mail.gmail.com>
References: <20100117133532.GB6178@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:61753 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab0AQUPL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 15:15:11 -0500
Received: by ewy19 with SMTP id 19so2672804ewy.21
        for <netdev@vger.kernel.org>; Sun, 17 Jan 2010 12:15:09 -0800 (PST)
In-Reply-To: <20100117133532.GB6178@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2010/1/17 Alexey Dobriyan <adobriyan@gmail.com>:
> __net_init/__net_exit are apparently not going away, so use them
> to full extent.
>
> In some cases __net_init was removed, because it was called from
> __net_exit code.

Maybe it's worth creating a __X_init_or_exit (or similar) for this
kind of functions? I.e. for modules it would put the code into .init
when modules are not unloadable or built in and so could be freed
after boot/module init.

Best Regards,
Micha=B3 Miros=B3aw
