From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 15:59:05 +0800
Message-ID: <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	<4B9FC7F1.5010507@google.com> <1268773227.2932.34.camel@edumazet-laptop>
	<20100316.141311.262178287.davem@davemloft.net> <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	<1268809673.2932.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:43716 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab0CQH70 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 03:59:26 -0400
Received: by iwn6 with SMTP id 6so725170iwn.4
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 00:59:25 -0700 (PDT)
In-Reply-To: <1268809673.2932.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 3:07 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 17 mars 2010 =C3=A0 09:54 +0800, Changli Gao a =C3=A9crit=
 :
>> On Wed, Mar 17, 2010 at 5:13 AM, David Miller <davem@davemloft.net> =
wrote:
>> >
>> > I'll integrate this as soon as I open up net-next-2.6
>>
>> It is really a good news. Now linux also can dispatch packets as
>> FreeBSD does via netisr. Can we walk farer, and support weighted
>> distribution?
>>
>
> May I ask why ? What would be the goal ?
>

=46or example, I have a firewall with dual core CPU, and use core 0 for
IRQ and dispatching. If I use both core 0 and core 1 for the left
processing, core 0 will be overloaded, and if I use core 1 for the
left processing, core 0 will be light load. In order to take full of
advantage of hardware, I need weighted the packet distribution.



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
