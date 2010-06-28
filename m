From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down interface
Date: Mon, 28 Jun 2010 23:09:02 +0200
Message-ID: <OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>	 <20100611084854.0680c014@nehalam>
	 <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se> <1277754121.4235.673.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:60812 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745Ab0F1VKq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 17:10:46 -0400
In-Reply-To: <1277754121.4235.673.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/06/28 21:42:01:
>
> Le lundi 28 juin 2010 =E0 21:03 +0200, Joakim Tjernlund a =E9crit :
> > Stephen Hemminger <shemminger@vyatta.com> wrote on 2010/06/11 17:48=
:54:
> > >
> > > When Linux is used as a router, it is undesirable for the kernel =
to process
> > > incoming packets when the address assigned to the interface is do=
wn.
> > > The initial problem report was for a management application that =
used ICMP
> > > to check link availability.
> > >
> > > The default is disabled to maintain compatibility with previous b=
ehavior.
> > > This is not recommended for server systems because it makes fail =
over more
> > > difficult, and does not account for configurations where multiple=
 interfaces
> > > have the same IP address.
> > >
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > Ping David et. all?
> > I too want this.
>
> You probably missed David reply
>
> http://permalink.gmane.org/gmane.linux.network/164494

Sure did, don't know how that happened, sorry.

Reading David's reply I do wonder about the current behaviour. Why
is it so important to keep responding to an IP address when the
admin has put the interface holding that IP address into administrative=
ly
down state? I don't think the weak host model stipulates that it must b=
e so, does it?

To me it "ifconfig eth0 down" means not only to stop using the I/F but
also any IP address associated with the I/F. I was rather surprised tha=
t
it didn't work that way. I don't see any way to make Linux stop respond=
ing to
that IP other that removing it completely from the system, which is rat=
her
awkward.

Note, I don't mean that the same should be applied for the No Carrier c=
ase, just
ifconfig down.

 Jocke


