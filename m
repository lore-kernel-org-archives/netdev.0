From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: l2tpv3 support not yet in iproute2?
Date: Mon, 27 Sep 2010 18:23:16 +0200
Message-ID: <1285604596.3017.80.camel@edumazet-laptop>
References: <loom.20100927T170521-559@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, James Chapman <jchapman@katalix.com>
To: jpo234 <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:45540 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759161Ab0I0QX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 12:23:26 -0400
Received: by ewy23 with SMTP id 23so1437710ewy.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 09:23:24 -0700 (PDT)
In-Reply-To: <loom.20100927T170521-559@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 15:22 +0000, jpo234 a =C3=A9crit :
> Hello all,
> some time ago James Chapman sent patches that add L2TPv3 support to i=
proute2:
> http://kerneltrap.org/mailarchive/linux-netdev/2010/3/18/6272266/thre=
ad
> While the kernel support arrived in 2.6.35 the user space configurati=
on support
> still seems to be missing:
> iproute2-2.6.35$ find . -type f -iname "*.c" | xargs fgrep -i l2tp
> doesn't find anything.
>=20
> Can somebody clarify the current situation?

Hmm, this reminds me l2tp locking is buggy and not yet fixed.

http://kerneltrap.org/mailarchive/linux-netdev/2010/4/20/6275106

James, any chance you could fix the locking ?



