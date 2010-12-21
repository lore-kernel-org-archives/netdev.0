From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: timestamp cloned packet in dev_queue_xmit_nit
Date: Tue, 21 Dec 2010 15:56:17 +0800
Message-ID: <AANLkTin6pzkUAcmH12ywTsRAABEKch9=iHziZ0oURZYd@mail.gmail.com>
References: <1292428252.3427.342.camel@edumazet-laptop> <20101216211744.GA2191@del.dom.local>
 <1292535039.2655.13.camel@edumazet-laptop> <20101216220838.GB2191@del.dom.local>
 <1292538363.2655.20.camel@edumazet-laptop> <20101216224237.GC2191@del.dom.local>
 <1292542305.2655.25.camel@edumazet-laptop> <20101217073015.GA6907@ff.dom.local>
 <1292573297.2655.42.camel@edumazet-laptop> <20101217083413.GB6907@ff.dom.local>
 <20101217085937.GC6907@ff.dom.local> <1292577988.2906.1.camel@edumazet-laptop>
 <1292916171.2627.184.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:36580 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab0LUH52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 02:57:28 -0500
Received: by fxm18 with SMTP id 18so3998383fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 23:57:27 -0800 (PST)
In-Reply-To: <1292916171.2627.184.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 3:22 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 17 d=E9cembre 2010 =E0 10:26 +0100, Eric Dumazet a =E9cri=
t :
>
>>
>> I think we can add this after latest Changli patch :
>>
>> He does one skb_clone() before calling the sniffers.
>> We could set timestamp on this clone, instead of original skb.
>>
>> Problem solved.
>>
>
> [PATCH net-next-2.6] net: timestamp cloned packet in dev_queue_xmit_n=
it
>
> Now we do one clone of skb if at least one sniffer might take packet,
> we also can do the skb timestamping on the clone and let original pac=
ket
> unchanged.
>
> This is a generalization of commit 8caf153974f2 (net: sch_netem: Fix =
an
> inconsistency in ingress netem timestamps.)
>
> This way, we can have a good idea when packets are delivered to our
> stack (tcpdump -i ifb0), while a tcpdump on original device gives
> timestamps right before ingressing.
>
> This also speedup our stack, avoiding taking timestamps if not needed=
=2E
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Changli Gao <xiaosuo@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jarek Poplawski <jarkao2@gmail.com>

Acked-by: Changli Gao <xiaosuo@gmail.com>


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
