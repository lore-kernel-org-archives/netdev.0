From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: red: split red_parms into parms and
 vars
Date: Fri, 06 Jan 2012 06:47:02 +0100
Message-ID: <1325828822.2748.27.camel@edumazet-laptop>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	 <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60791 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab2AFFrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 00:47:08 -0500
Received: by werm1 with SMTP id m1so895371wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 21:47:05 -0800 (PST)
In-Reply-To: <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 14:39 +0100, Eric Dumazet a =C3=A9crit =
:

> Problems of RED are :
>=20
> 1) the 'average' on highly variable trafic : It means nothing
> interesting at all.
>=20
> 2) the idle time management requires to specify the link bandwidth, a=
s a
> fixed value. This is a problem.

A third problem is that ECN marking is performed on the packet we add t=
o
the tail of the queue. It's very late...

I am currently testing my SFQRED and I try to add ECN in the first
packet in queue so that TCP can react faster.
