From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: 6to4: honour routing table
Date: Fri, 28 Aug 2009 23:55:32 -0700 (PDT)
Message-ID: <20090828.235532.253821244.davem@davemloft.net>
References: <3324b33c97aa3dba56e96b187db30042@chewa.net>
	<200908241148.17012.contact@saschahlusiak.de>
	<f40a9bc1410c815bf1932e27086162d8@chewa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbZH2GzS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 02:55:18 -0400
In-Reply-To: <f40a9bc1410c815bf1932e27086162d8@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Mon, 24 Aug 2009 12:02:51 +0200

>=20
>=20
> On Mon, 24 Aug 2009 11:48:12 +0200, Sascha Hlusiak
> <contact@saschahlusiak.de> wrote:
>> Attached patch is a compromise though which implements both but trie=
s the
>=20
>> destination address first and then the next hop. What would it break=
?
>=20
> I don't think it breaks anything per se. But userland will continue t=
o use
> compatible addresses forever anyway, so that it works with current ke=
rnel
> versions.

This is reason enough for me to not apply this patch.
