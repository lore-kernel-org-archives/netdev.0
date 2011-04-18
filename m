From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 08:38:27 -0700
Message-ID: <20110418083827.05dd2d43@nehalam>
References: <loom.20110418T154445-102@post.gmane.org>
	<1303135512.3137.335.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Buehler <aspam@cox.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40376 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290Ab1DRPic convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 11:38:32 -0400
In-Reply-To: <1303135512.3137.335.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011 16:05:12 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 18 avril 2011 =C3=A0 13:48 +0000, Joe Buehler a =C3=A9crit :
> > What does the LINUX network code put in the DSCP field of TCP SYN-A=
CK packets
> > that are replies to a SYN connection request?  I have a customer se=
nding SYN
> > with 0x2e in the DSCP field but apparently getting DSCP 0x0 in the =
reply.
>=20
> The other way (server->client) is depending on application and listen=
er
> only.
>=20
> If it uses a standard socket, standard bind() + listen(), TOS is 0

If you want to set DSCP in the response, the application needs to apply
set it on the listening socket.=20
   dscp =3D 0x2e;
   setsockopt(s, IPPROTO_IP, IP_TOS, &dscp, sizeof(dscp));
