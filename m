From: David Miller <davem@davemloft.net>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 12:23:12 -0800 (PST)
Message-ID: <20101201.122312.229751364.davem@davemloft.net>
References: <1291227893.2856.1039.camel@edumazet-laptop>
	<20101201.104450.183053379.davem@davemloft.net>
	<1291232937.2856.1042.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48820
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755840Ab0LAUWp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 15:22:45 -0500
In-Reply-To: <1291232937.2856.1042.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 20:48:57 +0100

> Le mercredi 01 d=E9cembre 2010 =E0 10:44 -0800, David Miller a =E9cri=
t :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 01 Dec 2010 19:24:53 +0100
>>=20
>> > A third work in progress (from my side) is to add a check in
>> > sk_chk_filter() to remove the memvalid we added lately to protect =
the
>> > LOAD M(K).
>>=20
>> I understand your idea, but the static checkers are still going to
>> complain.  So better add a huge comment in sk_run_filter() explainin=
g
>> why the checker's complaint should be ignored :-)
>=20
> Sure, here is the patch I plan to test ASAP

Looks good to me.
