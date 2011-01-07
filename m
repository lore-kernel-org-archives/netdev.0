From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: POLLPRI/poll() behavior change since 2.6.31
Date: Fri, 07 Jan 2011 14:31:45 +0100
Message-ID: <1294407105.3306.32.camel@edumazet-laptop>
References: <20110106155040.GA27769@libre.l.ngdn.org>
	 <1294332929.3074.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1101061429080.4928@davide-lnx1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Leonardo Chiquitto <leonardo.lists@gmail.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63179 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728Ab1AGNbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 08:31:51 -0500
Received: by wyb28 with SMTP id 28so17381765wyb.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 05:31:49 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1101061429080.4928@davide-lnx1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 14:40 -0800, Davide Libenzi a =C3=A9cri=
t :
> On Thu, 6 Jan 2011, Eric Dumazet wrote:
>=20
> > Hmm, this is because 	sock_def_readable() uses :
> >=20
> > wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLRDNORM |
> > POLLRDBAND);
> >=20
> > So POLLPRI bit is not signaled.=20
> >=20
> > I would just add POLLPRI flag in sock_def_readable()
> >=20
> > (Alternatively, define a tcp_def_readable() function to pass POLLPR=
I
> > only if TCP_URG is set, but is it worth the pain for a seldom used
> > feature ?)
>=20
> It would be kinda cleaner though, /me thinks.
>=20

Yep, we'll do this in net-next-2.6 for 2.6.39 :)

Thanks !


