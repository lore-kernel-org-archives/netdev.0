From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Wed, 21 Apr 2010 07:35:48 +0800
Message-ID: <v2s412e6f7f1004201635m5258e777oac49fea8f9625bcf@mail.gmail.com>
References: <1271769404.7895.10.camel@edumazet-laptop> <4BCDB425.9050007@lastsummer.de>
	<1271775421.7895.19.camel@edumazet-laptop> <20100420.144106.118596093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, franco@lastsummer.de, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.211.194]:46549 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab0DTXgJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:36:09 -0400
Received: by ywh32 with SMTP id 32so3697359ywh.33
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:36:08 -0700 (PDT)
In-Reply-To: <20100420.144106.118596093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 5:41 AM, David Miller <davem@davemloft.net> wro=
te:
> Eric, do you remember that "TCP friends" rough patch I sent you last
> year that essentailly made TCP sockets over loopback behave like
> AF_UNIX ones and just queue the SKBs directly to the destination
> socket without doing any protocol work?

I think it will break some benchmark tools. The loopback device is for
testing networking protocol stacks, so we shouldn't bypass the
protocol processing. And anyone who has a performance problem of
loopback device should turn to UNIX domain socket.

=46or routers, how about letting users choose whether RPS mixes layer 4=
 info in?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
