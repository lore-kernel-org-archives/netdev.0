From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Change netdev_fix_features messages loglevel
Date: Tue, 17 May 2011 15:45:21 -0400 (EDT)
Message-ID: <20110517.154521.1357718233260897046.davem@davemloft.net>
References: <20110516131757.ED57E13A6A@rere.qmqm.pl>
	<20110516.151434.829498612745581899.davem@davemloft.net>
	<20110516203739.GC18148@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	herbert@gondor.hengli.com.au, bhutchings@solarflare.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab1EQTph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:45:37 -0400
In-Reply-To: <20110516203739.GC18148@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 16 May 2011 23:37:39 +0300

> On Mon, May 16, 2011 at 03:14:34PM -0400, David Miller wrote:
>> From: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>> Date: Mon, 16 May 2011 15:17:57 +0200 (CEST)
>>=20
>> > Those reduced to DEBUG can possibly be triggered by unprivileged p=
rocesses
>> > and are nothing exceptional. Illegal checksum combinations can onl=
y be
>> > caused by driver bug, so promote those messages to WARN.
>> >=20
>> > Since GSO without SG will now only cause DEBUG message from
>> > netdev_fix_features(), remove the workaround from register_netdevi=
ce().
>> >=20
>> > Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
>>=20
>> Applied, thanks.
>=20
> Cool, how about we make 'Features changed' debug as well?
> This way userspace can't fill up the log just by tweaking tun feature=
s
> with an ioctl.
>=20
> Untested, but you get the message.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Agreed and applied.

I agree with Herbert's long term assertion that we should handle this
differently, somehow, to avoid these issues.

But as long as userspace can trigger these events, we have to do things
like decrease the logging level of these messages.
