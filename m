From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: ethernet QoS support?
Date: Fri, 9 Jul 2004 10:02:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407091002.26410.vkondra@mail.ru>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <40ED9A1C.4040707@pobox.com> <1089316845.1072.1.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1089316845.1072.1.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

I guess, Kumar is asking for support for several Tx queues with different 
priorities. One need to start/stop these queues separately. This is dictated 
by presense of different priorities on physical layer.

Kumar, is it 802.11? WME or TGE?

Vladimir.

On Thursday 08 July 2004 23:00, jamal wrote:
> On Thu, 2004-07-08 at 15:01, Jeff Garzik wrote:
> > Kumar Gala wrote:
> > > Jeff,
> > >
> > > I was wondering if there was any support for handling ethernet devices
> > > that support multiple RX/TX queues to provide QoS.  If so any pointers
> > > would be great.
> >
> > IIRC skb->priority provides priority bands for TX.  Not sure about RX...
> > jamal?
>
> The question was very ambigous.
> What is it that Kumar is looking for? Is it 802.1p, IP level etc?
>
> cheers,
> jamal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA7kMCqxdj7mhC6o0RAkeKAJ96kf49fbVy4qOjqqBBuNzmCteTrQCfU55Q
ke3RQ2prgMLEssvjeQIgegs=
=/KHu
-----END PGP SIGNATURE-----
