From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 21:28:03 +0100
Message-ID: <1330028883.15610.41.camel@edumazet-laptop>
References: <1330007786.15610.26.camel@edumazet-laptop>
	 <20120223.151115.1646872434333284038.davem@davemloft.net>
	 <1330028243.15610.40.camel@edumazet-laptop>
	 <20120223.152314.1111200746248162115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: darkbasic@linuxsystems.it, netdev@vger.kernel.org,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, 660804@bugs.debian.org,
	support@traverse.com.au, support@rocksolidelectronics.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57661 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab2BWU2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 15:28:11 -0500
Received: by wgbdt10 with SMTP id dt10so1432447wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 12:28:09 -0800 (PST)
In-Reply-To: <20120223.152314.1111200746248162115.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 15:23 -0500, David Miller a =C3=A9=
crit :

> I think the work to backport is equal whether you use a helper functi=
on
> or not.  Heck, use an inline function so you don't have to worry abou=
t
> module exports or any details like that.
>=20
> Besides, I'm the one who likely has to backport this thing, so... :-)

Great, I'll send an updated version in a couple of minutes ;)
