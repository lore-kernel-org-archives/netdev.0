From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IFB and bridges
Date: Sun, 11 Dec 2011 09:58:26 +0100
Message-ID: <1323593906.4016.42.camel@edumazet-laptop>
References: <1323566146.3159.186.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44425 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab1LKI6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 03:58:31 -0500
Received: by eekc4 with SMTP id c4so1105115eek.19
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 00:58:29 -0800 (PST)
In-Reply-To: <1323566146.3159.186.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 20:15 -0500, John A. Sullivan II=
I a =C3=A9crit :
> Hello, all.  This is more an "out of curiosity" question.  I'm starti=
ng
> to build a test environment for all I've learned about Linux traffic
> shaping over the last week.  One of the devices happens to be configu=
red
> as a bridge.  It quickly became apparent that I needed to do shaping =
on
> the individual ports and not the bridge port.
>=20
> This would be a real pain if I have lots of ports - 8 or 10 or 20
> identical configurations.  Would this be an ideal use for IFB? That i=
s,
> to redirect all ports to IFB and apply one set qdiscs/classes? Thanks=
 -

I have no idea what your problem is.

You want to shape either egress or ingress, for different reasons (most
people shape egress), but on proxies an ingress and egress combination
is welcomed.

But having to use ingress on the same machine in place of egress, I don=
t
see why.
