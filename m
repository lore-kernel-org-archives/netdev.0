From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] xen: netfront: fix declaration order
Date: Sun, 3 Apr 2011 19:35:26 +0200
Message-ID: <20110403173526.GA2082@rere.qmqm.pl>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl> <20110401.205455.70198735.davem@davemloft.net> <1301828839.2837.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeremy.fitzhardinge@citrix.com, konrad.wilk@oracle.com,
	Ian.Campbell@citrix.com, xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52897 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604Ab1DCRf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2011 13:35:29 -0400
Content-Disposition: inline
In-Reply-To: <1301828839.2837.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 03, 2011 at 01:07:19PM +0200, Eric Dumazet wrote:
> Le vendredi 01 avril 2011 =C3=A0 20:54 -0700, David Miller a =C3=A9cr=
it :
> > From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
> >=20
> > > Not tested in any way. The original code for offload setting seem=
s broken
> > > as it resets the features on every netback reconnect.
> > >=20
> > > This will set GSO_ROBUST at device creation time (earlier than co=
nnect time).
> > >=20
> > > RX checksum offload is forced on - so advertise as it is.
> > >=20
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > Applied.
> Hmm... I had to apply following patch to make it actually compile.

> [PATCH] xen: netfront: fix declaration order
>=20
> Must declare xennet_fix_features() and xennet_set_features() before
> using them.

Hmm. Sorry for that. Looks like x86 allyesconfig doesn't include this
driver in the build. :/

There really needs to be something like CONFIG_LINT...

Best Regards,
Micha=C5=82 Miros=C5=82aw

