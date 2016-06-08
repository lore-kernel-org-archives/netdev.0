From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Wed, 8 Jun 2016 13:52:48 +0200
Message-ID: <20160608115248.GA2603@salvia>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
 <1462843618-21914-2-git-send-email-me@tobin.cc>
 <20160607151458.GA18008@salvia>
 <1465319080.25087.28.camel@perches.com>
 <20160607173417.GA1141@salvia>
 <1465322550.25087.40.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tcharding <me@tobin.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48522 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756587AbcFHLx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 07:53:27 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 1A46C46B440
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 13:53:26 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0A646100A5F
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 13:53:26 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E71EB100A63
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 13:53:23 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1465322550.25087.40.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 11:02:30AM -0700, Joe Perches wrote:
> On Tue, 2016-06-07 at 19:34 +0200, Pablo Neira Ayuso wrote:
> > On Tue, Jun 07, 2016 at 10:04:40AM -0700, Joe Perches wrote:
> > > One more question, is this chunk below correct from
> > > coding style point of view?
> >=20
> > =A0=A0=A0=A0=A0=A0=A0=A0if (info->bitmask & EBT_STP_ROOTADDR) {
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0verdict =3D 0;
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0for (i =3D 0; i < 6=
; i++)
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]) &
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0verdict |=3D (stpc->root[2 + i] ^ c->root_addr[i]) &
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
> >=20
> > I think the previous line is fine.
>=20
> "2+i" or "2 + i", either is OK.
> Multiple line statement alignment doesn't
> matter much.

Sorry, I was actually refering to:

> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0verdict |=3D (stpc->root[2 + i] ^ c->root_addr[i]) &
> > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
                                    ^^^

instead of:

> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]) &
> > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0c->root_addrmsk[i];
                                       ^

here.

> I think either is fine and both are "don't care, don't need"
> to change from one to another to satisfy some silly whitespace
> overlord brainless script.
>=20
> Perhaps it's better to add a function for this though.

I like this function idea :).
