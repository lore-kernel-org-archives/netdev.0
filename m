From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Thu, 17 Mar 2016 09:47:47 +0100
Message-ID: <56EA6F33.6050603@6wind.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
 <20160313.215033.17951850162749485.davem@davemloft.net>
 <CAF2d9jhtvvEdmwP8OrOcUEn+P-Di0TRnjR7-RpcJrKJ3+HAN-Q@mail.gmail.com>
 <20160313.235358.1007563444789525672.davem@davemloft.net>
 <CAF2d9jgqAqUxN0HSTUguQyf6m62wDWizTH4bQ+Hz1xxte-=kaQ@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mahesh@bandewar.net, Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37496 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932199AbcCQIsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 04:48:05 -0400
Received: by mail-wm0-f48.google.com with SMTP id p65so106393860wmp.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 01:48:04 -0700 (PDT)
In-Reply-To: <CAF2d9jgqAqUxN0HSTUguQyf6m62wDWizTH4bQ+Hz1xxte-=kaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/03/2016 18:57, Mahesh Bandewar a =C3=A9crit :
> On Sun, Mar 13, 2016 at 8:53 PM, David Miller <davem@davemloft.net> w=
rote:
[snip]
>> Furthermore, when you walk across the ns boundary, that old device h=
as
>> to disappear.  That's why that is the device assigned to skb->dev.
>>
> The layer boundaries are not that well maintained. We do check for th=
e xfrm
> policies in L4 and expect the skb->dev pointing to the L3 device. So =
unless we
> have a way to derive a L3 dev from skb->dev, I don't think xfrm will
> work. Unless
> some Xfrm-expert asserts that this is not needed.
Adding a hook "at the right place" to do the switch is probably the bet=
ter way.
=46or xfrm, you will need to handle it in this hook or rearrange things=
=2E
I don't think that a quick and easy solution will be possible.
