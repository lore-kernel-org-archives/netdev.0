From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 7 Sep 2010 02:21:42 -0300
Message-ID: <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
References: <AANLkTike9biiUvAhckJKHCB6dyS4PzHgFFPF5RNEw4PP@mail.gmail.com>
 <1283834219.2585.455.camel@edumazet-laptop> <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
 <20100906.221644.123986391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51873 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076Ab0IGFWE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:22:04 -0400
Received: by fxm13 with SMTP id 13so2797095fxm.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 22:22:02 -0700 (PDT)
In-Reply-To: <20100906.221644.123986391.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 7, 2010 at 2:16 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: =E3=83=84 Leandro Melo de Sales <leandroal@gmail.com>
> Date: Tue, 7 Sep 2010 02:13:46 -0300
>
>> 192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.34=C2=A0=C2=A0=C2=A0 [SYN, =
ACK] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MSS=3D78
>
> Find out why this system is advertising a 78 byte window
> with no window scaling.
>

This is a embedded system implemented in a proprietary hardware that I
can send TCP commands to turn on/off relays. It will be very difficult
to find the reason for this behaviour. Since it needs to receive very
small data, probably it is not necessary to scaling window.

Leandro.
