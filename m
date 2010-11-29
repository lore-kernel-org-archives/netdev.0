From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net-next: Fix __inet_inherit_port() to correctly
	increment bsockets and num_owners
Date: Mon, 29 Nov 2010 13:33:20 +0000
Message-ID: <20101129133320.GA9759@ff.dom.local>
References: <20101128230041.GA16269@ioremap.net> <20101129123909.GA9286@ff.dom.local> <20101129125102.GA17736@ioremap.net> <20101129131201.GB9286@ff.dom.local> <1291036666.3435.435.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Nagendra Tomar <tomer_iisc@yahoo.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54868 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab0K2NdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 08:33:23 -0500
Received: by fxm8 with SMTP id 8so82850fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 05:33:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291036666.3435.435.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 29, 2010 at 02:17:46PM +0100, Eric Dumazet wrote:
> Le lundi 29 novembre 2010 ?? 13:12 +0000, Jarek Poplawski a =E9crit :
>=20
> > Evgeniy & Eric,

Eric & Evgeniy ;-)

> > But it's compared to the numer of available port numbers in
> > inet_csk_get_port():
> >=20
> >      "if (atomic_read(&hashinfo->bsockets) > (high - low) + 1)"
> >=20
> > Can't you have bsockets higher than this with only one port used?
> >=20
>=20
> Because we store tuples, not only port information.
>=20
> You can have many sockets bound on a single port.
>=20
> This 'optimization' was only meaningful on a machine you make only
> active connections, if you ask me...

That's what I've missed...

> Problem is, as soon as some passive connections are done, bsockets co=
unt
> becomes wrong. The patch fixes this, thats all.

Sure, the numbers are correct now. I wondered about this optimization
only.

Thanks for explanations,
Jarek P.
