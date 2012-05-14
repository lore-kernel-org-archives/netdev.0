From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH] [RFC] netfilter: don't assume NFPROTO_* are like PF_*
Date: Mon, 14 May 2012 16:42:30 +0100
Message-ID: <20120514164230.6b9078bd@rainbow.cbg.collabora.co.uk>
References: <1337003909-2582-1-git-send-email-alban.crequy@collabora.co.uk>
	<alpine.LNX.2.01.1205141707490.11548@frira.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:48907 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756965Ab2ENPm3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 11:42:29 -0400
In-Reply-To: <alpine.LNX.2.01.1205141707490.11548@frira.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 14 May 2012 17:09:54 +0200 (CEST),
Jan Engelhardt <jengelh@inai.de> a =C3=A9crit :

>=20
> On Monday 2012-05-14 15:58, Alban Crequy wrote:
> >--- a/include/linux/netfilter.h
> >+++ b/include/linux/netfilter.h
> >@@ -62,11 +62,11 @@ enum nf_inet_hooks {
> >=20
> > enum {
> > 	NFPROTO_UNSPEC =3D  0,
> >-	NFPROTO_IPV4   =3D  2,
> >-	NFPROTO_ARP    =3D  3,
> >-	NFPROTO_BRIDGE =3D  7,
> >-	NFPROTO_IPV6   =3D 10,
> >-	NFPROTO_DECNET =3D 12,
> >+	NFPROTO_IPV4,
> >+	NFPROTO_ARP,
> >+	NFPROTO_BRIDGE,
> >+	NFPROTO_IPV6,
> >+	NFPROTO_DECNET,
> > 	NFPROTO_NUMPROTO,
> > };
>=20
> This must not be changed under any circumstances. It is exported to
> and used by userspace. (Except perhaps for NFPROTO_DECNET, which
> refers to a quite dead protocol that I think no user parts have ever
> used NFPROTO_DECNET.) I would consider it acceptable to change the
> value for NFPROTO_DECNET if Pablo joins.

Thanks for the review. I didn't realize it was exported to and used by
userspace. I would drop this patch then.

Alban
