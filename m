From: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 8 Jan 2015 16:24:10 +0100
Message-ID: <54AEA11A.1000603@uclouvain.be>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be> <1420729656.5947.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33780 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbbAHPYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:24:30 -0500
In-Reply-To: <1420729656.5947.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Le 08/01/2015 16:07, Eric Dumazet a =C3=A9crit :
>
>>   In the current code,
>> such ACK+DSACK will be missed and only at next, higher ack will the =
TLP
>> episode be considered done. Since the DSACK is not present anymore,
>> this will cost a cwnd reduction.
>>
>> This patch ensures that this scenario does not cause a cwnd reductio=
n, since
>> receiving an ACK+DSACK indicates that both the initial segment and t=
he probe
>> have been received by the peer.
> Do you have at hand a packetdrill test to demonstrate that the patch
> works ?
Not currently, but that would be very good indeed.
I will prepare one and send it.

regards,

S=C3=A9bastien.
>
> Thanks !
>
>
