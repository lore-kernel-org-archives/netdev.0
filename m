From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Thu, 10 Jun 2004 08:55:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406100855.37348.vkondra@mail.ru>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <200406092127.28477.vkondra@mail.ru> <1086832740.1205.65.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1086832740.1205.65.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thursday 10 June 2004 04:59, jamal wrote:
> On Wed, 2004-06-09 at 14:27, Vladimir Kondratiev wrote:
> > Sure. I know when each DMA queue have space to accept new packets. w.r.t
> > Tx discipline, it is really like 4 (taking into account TSPEC, see my
> > mail about TGe, minimum 5 for STA and 6 (i did not said about power save
> > buffering) for AP) independent devices.
>
> Vladimir - do you have one of these cards? Jean is putting some my
> doubts in my mind about their designs. Do they have seperate DMA rings?
Good question. Until I can really answer, let's say "in theory, all next 
generation wireless cards should have similar design". Hint: I have also mail 
ending by intel.com
>
> > I see you got the idea. Question is, how to implement it.
>
> As suggested earlier:
> - introduce id and id_state per ring.
> - use a skb tag to select id
skb->priority, correct?
> - if ring is full, use same id to requeue to qdisc.
how?
> - qdiscs above must have semantics that map to the strict priority
> scheme (eg you could use CBQ which does both priorities and bandwith
> allocation or use simple prio or strict prio qdiscs).
> - netif stopping and starting is done per id/ring.
how to do it? I am afraid several network interfaces is not a good idea.
>
> Did i miss something?
Sounds good. Next step is integrated service, where, prior to use some 
priority, STA have to allocate bandwidth and get admission from AP.
>
> Do you wanna try this? I could give you a hand but dont have much time
> to code at the moment. I could point you to the different pieces of code
> that need mods and suggest the changes.
It would be great help. Please...
I promise to share results.
>
> cheers,
> jamal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAx/fZqxdj7mhC6o0RAv/6AJ9r0zqZN8E1Y6UFUBH+0Ikfl6yRPQCgqhCJ
OmLUtIXWDjtI8RpQcsUvQJ0=
=agJJ
-----END PGP SIGNATURE-----
