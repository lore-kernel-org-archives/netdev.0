From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Thu, 09 Feb 2012 19:05:07 +0100
Message-ID: <1328810707.6099.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F33FC0E.4020701@msgid.tls.msk.ru>
	 <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41041 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757894Ab2BISFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:05:11 -0500
Received: by werb13 with SMTP id b13so1443718wer.19
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2012 10:05:10 -0800 (PST)
In-Reply-To: <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 f=C3=A9vrier 2012 =C3=A0 18:45 +0100, Eric Dumazet a =C3=A9=
crit :

> Did you try to apply by hand commits :
>=20
> 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae   // added in 3.2
> (route: fix ICMP redirect validation)
>=20
> and
> 9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
> (ipv4: fix redirect handling)

Oh well, please forgive my stupid questions.

David is currently working on backporting to 3.0 all necessary fixes fo=
r
this exact problem.
