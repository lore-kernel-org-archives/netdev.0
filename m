From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: ethernet QoS support?
Date: Fri, 9 Jul 2004 16:41:30 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407091641.35651.vkondra@mail.ru>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <200407091002.26410.vkondra@mail.ru> <1089379137.1047.242.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1089379137.1047.242.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 09 July 2004 16:18, jamal wrote:
> On Fri, 2004-07-09 at 03:02, Vladimir Kondratiev wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >
> > I guess, Kumar is asking for support for several Tx queues with different
> > priorities. One need to start/stop these queues separately. This is
> > dictated by presense of different priorities on physical layer.
>
> Exactly. I referenced him to you. Have you started any work yet?
>
> cheers,
> jamal
Yes, I do.
So far, I have hardware related parts working. I rely on skb->priority to 
determine traffic class and select proper queue.

All this worth nothing if one can't do separate queues. qdisc assignment for 
driver is not in driver's hands, so it can't do any assumptions. Generic 
in-kernel support needed here. Stack should allow driver to request 
additional Tx queues, providing some classifiers for each one. I tried to 
imagine how to work it around, but there is no good solution without those 
several queues.

This mean, I will be able to deliver QoS support when network stack will make 
it possible.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA7qCPqxdj7mhC6o0RAoFEAJ4j3a7ekravvh9vQC229M5a8PXcHACfY5Rp
PuvymlVUopAiUyNGqbSMl/c=
=gvWz
-----END PGP SIGNATURE-----
