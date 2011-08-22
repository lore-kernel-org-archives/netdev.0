From: Li Yu <raise.sail@gmail.com>
Subject: Re: [net-next PATCH] tcp: remove useless assignment statement in
 tcp_keepalive_timer
Date: Mon, 22 Aug 2011 19:01:19 +0800
Message-ID: <4E5236FF.4080608@gmail.com>
References: <4E52295D.8040901@gmail.com> <201108221346.13210.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb18030
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:41103 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab1HVLB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:01:26 -0400
Received: by pzk37 with SMTP id 37so8479336pzk.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 04:01:25 -0700 (PDT)
In-Reply-To: <201108221346.13210.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Oops, thanks for reminding !

Yu

=D3=DA 2011=C4=EA08=D4=C222=C8=D5 18:46, Christoph Paasch =D0=B4=B5=C0:
> No, if the condition afterwards evaluates to TRUE, and we go to the l=
abel=20
> resched, inet_csk_reset_keepalive_timer(...) is called without elapse=
d being=20
> set.
>=20
> Cheers,
> Christoph
>=20
> On Monday 22 August 2011 wrote Li Yu:
>> Remove useless assignment statement, it may be trash after refactori=
ng?
>>
>> Signed-off-by: Li Yu <raise.sail@gmail.com>
>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>> index ecd44b0..321ff2f 100644
>> --- a/net/ipv4/tcp_timer.c
>> +++ b/net/ipv4/tcp_timer.c
>> @@ -552,8 +552,6 @@ static void tcp_keepalive_timer (unsigned long d=
ata)
>>  	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state =3D=3D TCP_CLOSE=
)
>>  		goto out;
>>
>> -	elapsed =3D keepalive_time_when(tp);
>> -
>>  	/* It is alive without keepalive 8) */
>>  	if (tp->packets_out || tcp_send_head(sk))
>>  		goto resched;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --
> Christoph Paasch
> PhD Student
>=20
> IP Networking Lab --- http://inl.info.ucl.ac.be
> MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
> Universit=A8=A6 Catholique de Louvain
>=20
> www.rollerbulls.be
> --
>=20
