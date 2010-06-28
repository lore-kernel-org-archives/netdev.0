From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Mon, 28 Jun 2010 21:42:01 +0200
Message-ID: <1277754121.4235.673.camel@edumazet-laptop>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
	 <20100611084854.0680c014@nehalam>
	 <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:60217 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab0F1TmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 15:42:07 -0400
Received: by wwd20 with SMTP id 20so283700wwd.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 12:42:04 -0700 (PDT)
In-Reply-To: <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 21:03 +0200, Joakim Tjernlund a =C3=A9crit=
 :
> Stephen Hemminger <shemminger@vyatta.com> wrote on 2010/06/11 17:48:5=
4:
> >
> > When Linux is used as a router, it is undesirable for the kernel to=
 process
> > incoming packets when the address assigned to the interface is down=
=2E
> > The initial problem report was for a management application that us=
ed ICMP
> > to check link availability.
> >
> > The default is disabled to maintain compatibility with previous beh=
avior.
> > This is not recommended for server systems because it makes fail ov=
er more
> > difficult, and does not account for configurations where multiple i=
nterfaces
> > have the same IP address.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> Ping David et. all?
> I too want this.

You probably missed David reply

http://permalink.gmane.org/gmane.linux.network/164494



