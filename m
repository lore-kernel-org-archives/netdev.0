From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: kernel 2.4 vs 2.6 Traffic Controller performance
Date: Wed, 03 Oct 2007 09:00:32 +0200
Message-ID: <47033E10.6090505@cosmosbay.com>
References: <9dbec86d0710022314o6db2b0baua6db543d52f312b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sonny <smaniaol@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39044 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbXJCHAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 03:00:44 -0400
In-Reply-To: <9dbec86d0710022314o6db2b0baua6db543d52f312b6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sonny a =E9crit :
> Hello
> This is a repost, there seems to have a misunderstanding before.
>=20
> I hope this is the right place to ask this. Does any know if there is=
 a
> substantial difference in the performance of the traffic controller
> between kernel 2.4 and 2.6. We tested it using 1 iperf server and use
> 250 and 500 clients, altering the burst.
>=20
> This is the set-up:
> iperf client -  router (w/ traffic controller) - iperf server
>=20
> We use the top command inside the router to check the idle time of ou=
r
> router to see this. The results we got from the 2.4 kernel shows
> around 65-70% idle time while the 2.6 shows
> 60-65% idle time. We tried to use MRTG and we're not getting any
> results either. We want to know if we could improve the bandwidth by
> upgrading the kernel, else we would have to get a new bandwidth
> manager.  Have anyone performed a similar test or can suggest a bette=
r
> way to do this. Thanks in advance.
> -
Hi Sonny

I am not sure what you are asking here. 65-70% idle time (or 60-65%) is=
 fine.

2.6 is also not very meaningfull, there are a lot of changes between 2.=
6.0 and=20
2.6.23 :)

Why should you upgrade kernel ?
What bandwidth do you handle ?
What kind of platform is it ? (a new kernel wont help much if its a rea=
l old=20
machine, or old NICs)

You seem to have some bandwidth problem but focus on cpu affairs...

