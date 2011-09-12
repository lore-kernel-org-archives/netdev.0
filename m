From: Kumar S <ps2kumar@yahoo.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Mon, 12 Sep 2011 15:20:34 -0700 (PDT)
Message-ID: <1315866034.38403.YahooMailNeo@web113918.mail.gq1.yahoo.com>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>  <1315546223.5410.23.camel@edumazet-laptop>  <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>  <1315596786.2606.3.camel@edumazet-laptop>  <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>  <1315604820.2606.13.camel@edumazet-laptop>  <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>  <1315606125.2606.19.camel@edumazet-laptop>  <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>  <20110910130416.GA2005@neilslaptop.think-freely.org>  <1315798710.96027.YahooMailNeo@web113913.mail.gq1.yahoo.com>  <1315806031.3174.16.camel@edumazet-laptop>  <1315807643.92529.YahooMailNeo@web113911.mail.gq1.yahoo.com>  <1315808931.3174.17.camel@edumazet-laptop>  <1315847801.41447.YahooMailNeo@web113
 916.mail.gq1.yahoo.com> <1315850272.2556.0.camel@edumazet-laptop>
Reply-To: Kumar S <ps2kumar@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm24.bullet.mail.sp2.yahoo.com ([98.139.91.94]:47998 "HELO
	nm24.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755182Ab1ILWUf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Sep 2011 18:20:35 -0400
In-Reply-To: <1315850272.2556.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
=46rom: Eric Dumazet <eric.dumazet@gmail.com>
To: Kumar S <ps2kumar@yahoo.com>
Cc: Neil Horman <nhorman@tuxdriver.com>; netdev <netdev@vger.kernel.org=
>
Sent: Monday, September 12, 2011 10:57 AM
Subject: Re: Memory leak in ip_dst_cache

Le lundi 12 septembre 2011 =E0 10:16 -0700, Kumar S a =E9crit :
>> ----- Original Message -----
>> From: Eric Dumazet <eric.dumazet@gmail.com>

>>What do you mean ? Your box is a router only ?
>>=20
> >>Those SMB messages are going through it ?
>=A0>=20
>> Our box is a stand-alone system with L2 Quick Engine. This QE forwar=
ds
>> all broadcast to the other ports and also a copy to the CPU port.=20

>It sounds like a modified kernel, maybe you added a bug in the code...

It is possible. I'm trying to isolate the same. Your input=A0is helping=
 a lot in understanding the flow related to ip_dst_cache.=20
