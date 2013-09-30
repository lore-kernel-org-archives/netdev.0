From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: qmi_wwan: fix checkpatch warnings
Date: Mon, 30 Sep 2013 15:00:09 -0400 (EDT)
Message-ID: <20130930.150009.1201441098562675548.davem@davemloft.net>
References: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
	<1380100886-16531-2-git-send-email-fabio.porcedda@gmail.com>
	<877ge5own8.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.porcedda@gmail.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, dcbw@redhat.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265Ab3I3TAL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 15:00:11 -0400
In-Reply-To: <877ge5own8.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Wed, 25 Sep 2013 15:31:39 +0200

> Sorry, I really don't see the point of this.  Yes, the lines are long=
er
> than 80 columns, but breaking them don't improve the readability at
> all.  On the contrary, IMHO.
>=20
> So NAK from me for this part.

Sorry, breaking things up like this is what we do everywhere.

It's not strictly 80 columns but "about 80 columns".

And the only place we don't break things up is for messages that end
up in the kernel log.  Those strings can take the line as long as is
reasonably necessary.

But at argument delimiters and operators for long complex expressions,
we break it up so that the lines do not significantly exceed 80
columns.

Anything else is your opinion, and not what we've been trying to do
consistently across the kernel and in particular in the networking.

Therefore this patch is perfectly fine and I intent to apply it.
