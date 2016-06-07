From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] bridge: netfilter: checkpatch whitespace fixes
Date: Tue, 7 Jun 2016 19:34:17 +0200
Message-ID: <20160607173417.GA1141@salvia>
References: <1462843618-21914-1-git-send-email-me@tobin.cc>
 <1462843618-21914-2-git-send-email-me@tobin.cc>
 <20160607151458.GA18008@salvia>
 <1465319080.25087.28.camel@perches.com>
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
Received: from mail.us.es ([193.147.175.20]:59141 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755573AbcFGReW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 13:34:22 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CB9E59432EF
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 19:34:20 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BD29E9EBB4
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 19:34:20 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C70839EBAD
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 19:34:17 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1465319080.25087.28.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 10:04:40AM -0700, Joe Perches wrote:
> On Tue, 2016-06-07 at 17:14 +0200, Pablo Neira Ayuso wrote:
> > On Tue, May 10, 2016 at 11:26:56AM +1000, tcharding wrote:
> > > From: Tobin C Harding <me@tobin.cc>
> > > This is my second linux kernel patch. Unsure if I was meant to cc=
 multiple mailing lists?
> []
> > > diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilte=
r/ebt_stp.c
> []
> > > @@ -55,65 +55,65 @@ static bool ebt_filter_config(const struct eb=
t_stp_info *info,
> > > =A0	if (info->bitmask & EBT_STP_ROOTPRIO) {
> > > =A0		v16 =3D NR16(stpc->root);
> > > =A0		if (FWINV(v16 < c->root_priol ||
> > > -		=A0=A0=A0=A0v16 > c->root_priou, EBT_STP_ROOTPRIO))
> > > +			=A0=A0v16 > c->root_priou, EBT_STP_ROOTPRIO))
> > I don't think this coding style is right. This is a common approach
> > (to align the condition when split in several lines) in other 'net'=
 code.
>=20
> Perhaps you misread the code.

Oh right. This FWINV() got me confused.

> The alignment is changed for the 1st argument of the FWINV macro
> to be more similar to the style used in the rest of net/
>=20
> But using a longer initial line would be more readable:
>=20
> =A0		if (FWINV(v16 < c->root_priol ||=A0v16 > c->root_priou,
> 			=A0=A0EBT_STP_ROOTPRIO))

I see. Thanks for clarifying all the FWINV() related changes.

One more question, is this chunk below correct from coding style point
of view?

        if (info->bitmask & EBT_STP_ROOTADDR) {
                verdict =3D 0;
                for (i =3D 0; i < 6; i++)
-                       verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]=
) &
-                                  c->root_addrmsk[i];
+                       verdict |=3D (stpc->root[2 + i] ^ c->root_addr[=
i]) &
+                               c->root_addrmsk[i];

I think the previous line is fine.
