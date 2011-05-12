From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding,llc: Fix structure sizeof incompatibility for
 some PDUs
Date: Thu, 12 May 2011 18:02:13 +0200
Message-ID: <1305216133.3795.31.camel@edumazet-laptop>
References: <201105121557.06679.vitas@nppfactor.kiev.ua>
	 <1305210816.5214.9.camel@bwh-desktop>
	 <201105121845.49090.vitas@nppfactor.kiev.ua>
	 <1305215554.6124.35.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vitalii Demianets <vitas@nppfactor.kiev.ua>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60498 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337Ab1ELQCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 12:02:18 -0400
Received: by wwk4 with SMTP id 4so5597748wwk.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 09:02:17 -0700 (PDT)
In-Reply-To: <1305215554.6124.35.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 mai 2011 =C3=A0 08:52 -0700, Joe Perches a =C3=A9crit :
> On Thu, 2011-05-12 at 18:45 +0300, Vitalii Demianets wrote:
> > On Thursday 12 May 2011 17:33:36 Ben Hutchings wrote:
> > [...]
> > > The '__packed' macro is preferred.
> > Also, I'm slightly in doubt if I should split the patch in 2 parts,=
 one for=20
> > bonding an one for LLC?
>=20
> What arch needs __packed for
>=20
> struct mac_addr {
> 	unsigned char addr[6];
> };
>=20
> ?

Believe it or not, they do exist.  (ARM ...)

See "struct ethhdr" definition=20

Check commit 7cd636fe9ce5de0051c112 for another argument.


