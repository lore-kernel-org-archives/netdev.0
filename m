From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Sun, 26 Sep 2010 08:09:58 +0200
Message-ID: <1285481398.2436.7.camel@edumazet-laptop>
References: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
	 <20100924.223709.233700415.davem@davemloft.net>
	 <1285394797.2478.54.camel@edumazet-laptop>
	 <20100925.001300.193725148.davem@davemloft.net>
	 <1285405945.2478.255.camel@edumazet-laptop>
	 <1285457597.2697.183.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, romieu@fr.zoreil.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47712 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab0IZGKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 02:10:04 -0400
Received: by fxm3 with SMTP id 3so1333295fxm.19
        for <netdev@vger.kernel.org>; Sat, 25 Sep 2010 23:10:03 -0700 (PDT)
In-Reply-To: <1285457597.2697.183.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 septembre 2010 =C3=A0 00:33 +0100, Ben Hutchings a =C3=A9=
crit :
> On Sat, 2010-09-25 at 11:12 +0200, Eric Dumazet wrote:
> [...]
> > The r8169 current problem is its currently copying all incoming fra=
mes.
> > I guess nobody cares or noticed the performance drop.
> > (But commit c0cd884a is recent (2.6.34), this is not yet in
> > production...)
>=20
> Since that was a security fix it was backported to 2.6.32.12 and
> probably most distribution kernels.  So yes it is in production.

Maybe in your company, not a single machine in mine ;)

Most linux servers in production run much older kernels.

rhel 5 -> 2.6.18
debian 5 -> 2.6.26.x



