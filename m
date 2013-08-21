From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Passing sk_buff metadata information to user space in
 TUNTAP driver.
Date: Tue, 20 Aug 2013 23:28:36 -0700 (PDT)
Message-ID: <20130820.232836.1603560215048485459.davem@davemloft.net>
References: <1376944177-20031-1-git-send-email-vytautas.valancius@gmail.com>
	<CAHo-Ooy4S8tzOBqZQJEEvkAqMJdYCf2XTYZpkFHk=PZJP7z-Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vytautas.valancius@gmail.com, valas@google.com,
	edumazet@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab3HUG2i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:28:38 -0400
In-Reply-To: <CAHo-Ooy4S8tzOBqZQJEEvkAqMJdYCf2XTYZpkFHk=PZJP7z-Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 19 Aug 2013 13:49:08 -0700

> Acked-by: Maciej =AFenczykowski <maze@google.com>
>=20
> I've already reviewed / commented on previous versions of this patch
> and am hoping for comments from a wider audience.
>=20
> I'm hoping this relatively generic and easily extensible way of
> exposing additional per-packet metadata to userspace catches on.
> Something similar would also be useful for tcpdump (ie. raw packet so=
ckets).

I'd rather people build generic infrastructure for this.

We already have a META match in the packet scheduler, and all sorts
of BPF extensions which provide SKB metadata too.  That's the right
approach, something more generic.

Therefore, putting a custom version of SKB metadata export into the
TUN driver makes absolutely no sense to me.

I'm not applying this, sorry.
