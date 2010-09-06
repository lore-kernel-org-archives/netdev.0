From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Mon, 06 Sep 2010 22:29:15 +0200
Message-ID: <1283804955.2585.12.camel@edumazet-laptop>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35628 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165Ab0IFU3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:29:21 -0400
Received: by wwj40 with SMTP id 40so7044426wwj.1
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 13:29:20 -0700 (PDT)
In-Reply-To: <4C854737.5040503@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 septembre 2010 =C3=A0 21:55 +0200, Krzysztof Ol=C4=99dzki a=
 =C3=A9crit :

> Yes, conntrack is one of possibilities. However, this problem only=20
> manifests on 2.6.34 and never on 2.6.31 where iptables and conntrack=20
> configurations are identically. And of course, each time it is a=20
> different port.
>=20
> Please also note that this problem only exists when communication is=20
> handled over a loopback interface - I'm not able to trigger this from=
 a=20
> remote host even if I run the test on two hosts (local & remote)=20
> simultaneously.
>=20

No particular error shown in "netstat -s" ?

port randomization on UDP changed in the past, and conntracking changed
a bit too ;)





