From: BZ Benny <bennybbz@yahoo.fr>
Subject: Re: creating a netdevice
Date: Thu, 3 Mar 2005 10:36:21 +0100 (CET)
Message-ID: <20050303093621.29849.qmail@web26609.mail.ukl.yahoo.com>
References: <1109799677.1098.198.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
To: netdev@oss.sgi.com
In-Reply-To: <1109799677.1098.198.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
tanks a lot, I think that the only way for creating a
netdevice without being in the kernel space its to use
tuntap.=20

I have an appli like blueZ which access to the IP
layer and take paket into another network.

My appli run under a PC wich play the role of an
access point for other PCs in my private network.

So, for driving packet from internet to my private=20
network and vice versa I use briding utils: brctl

but I have another problem.
It s that my bridge br0 that i create like that
#brctl addbr br0=20
#brctl setfd br0 0
#brctl stp br0 off=20
#brctl addif br0 eth0
#brctl addif br0 tun0


but if I do not=20
#ifconfig eth0 0.0.0.0
#ifconfig br0 10.160.15.128
#route add default gw 10.160.15.128

I can"t access to internet, why does br0 need an IP
adress. I want to not giving him an IP adress and
giving eth0 the IP address of my internet network and
tun0 the IP adress of my private network.


regards
imad.

ps: blueZ is an open source bluetooth stack which is
integrated to the 2.6 kernels.



 --- jamal <hadi@cyberus.ca> a =E9crit :=20
>=20
> Can you explain why you need to create a net device?
> Linux (and many
> other OSes) typically tie discovery of hardware
> resources to creating a
> network device i.e the kernel creates it for you
> (this is true even when
> the discovery is done post bootup). The only
> exception is things like=20
> tun/ethertap as Stephen mentions. Things like
> allocation of ifindices=20
> are also under the control of the OS - even when you
> are able to create.
>=20
> cheers,
> jamal
>=20
>=20
> On Wed, 2005-03-02 at 14:26, Stephen Hemminger
> wrote:
> > On Wed, 2 Mar 2005 14:38:28 +0100 (CET)
> > BZ Benny <bennybbz@yahoo.fr> wrote:
> >=20
> > > Hi
> > >=20
> > > I want to create a network interface from the
> user
> > > space,
> > > is it possible?
> >=20
> > No, you can't create a network interface from user
> space.
> > You probably want to use tun/tap or ethertap
> device.
> >=20
> >=20
>=20
>=20
> =20


=09

=09
	=09
D=E9couvrez le nouveau Yahoo! Mail : 250 Mo d'espace de stockage pour vos=
 mails !=20
Cr=E9ez votre Yahoo! Mail sur http://fr.mail.yahoo.com/
