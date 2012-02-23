From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 15:39:06 +0100
Message-ID: <1330007946.15610.28.camel@edumazet-laptop>
References: <bug-42809-100@https.bugzilla.kernel.org/>
	 <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
	 <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it>
	 <1329961083.15610.2.camel@edumazet-laptop>
	 <4F459E37.9010507@linuxsystems.it>
	 <1329962785.15610.8.camel@edumazet-laptop>
	 <4F46430D.3060802@linuxsystems.it>
	 <1330007786.15610.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>, openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: =?ISO-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65219 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817Ab2BWOjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 09:39:14 -0500
Received: by wgbdt10 with SMTP id dt10so1152519wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 06:39:13 -0800 (PST)
In-Reply-To: <1330007786.15610.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 15:36 +0100, Eric Dumazet a =C3=A9=
crit :

> [PATCH] ipsec: be careful of non existing mac headers
>=20
> Nicollo Belli reported ipsec crashes in case we handle a frame withou=
t
> mac header (atm in his case)

Oops sorry for your name being mangled in changelog, its Niccol=C3=B2 a=
s
correctly spelled in the "Reported-by" and "Tested-by" tags
