From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: IPv6 tunnel scalability problem
Date: Mon, 1 Sep 2008 18:09:26 +0300
Message-ID: <200809011809.26410.rdenis@simphalempin.com>
References: <200808311958.51510.rdenis@simphalempin.com> <8763pgxead.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Bernhard Schmidt <berni+ipv6@birkenwald.de>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:43886 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbYIAPJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 11:09:29 -0400
In-Reply-To: <8763pgxead.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 1 septembre 2008 15:04:58 Andi Kleen, vous avez =C3=A9crit=C2=A0=
:
> R=C3=A9mi Denis-Courmont <rdenis@simphalempin.com> writes:
> > I have been maintaining a TUN-based Linux implementation of
> > Teredo/RFC4380. On a busy node, this can trigger quite many peers o=
n the
> > virtual point-to-point tunnel interface. I have received complaints=
 that
> > the whole thing seems to hit some severe performance bottleneck whe=
n this
> > happens. It is not clear to me at this point whether it's a kernel =
or a
> > user problem. So I have been writing a stress test.
>
> You could use oprofile to find out where the CPU time is going.
> That would work even during normal operation. Post the opreport -l ou=
tput

Understood. But this far, the kernel crashes during my stress test...

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
