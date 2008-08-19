From: Artem Bityutskiy <dedekind@infradead.org>
Subject: Re: [PATCH] Remove duplicated unlikely() in IS_ERR()
Date: Tue, 19 Aug 2008 17:57:38 +0300
Message-ID: <1219157858.18027.44.camel@sauron>
References: <48A52D69.1040501@miraclelinux.com>
	 <1219125321.18027.9.camel@sauron>
Reply-To: dedekind@infradead.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, christof.schmitt@de.ibm.com,
	netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-s390@vger.kernel.org
To: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:26035 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbYHSPAO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 11:00:14 -0400
In-Reply-To: <1219125321.18027.9.camel@sauron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-08-19 at 08:55 +0300, Artem Bityutskiy wrote:
> On Fri, 2008-08-15 at 16:16 +0900, Hirofumi Nakagawa wrote:
> > Hi
> > Some drivers have duplicated unlikely() macros.
> > IS_ERR() already has unlikely() in itself.
> > This patch cleans up such pointless codes although there is no real
> > effect on the kernel's behaviour.
> >=20
> > Thanks,
> > Hirofumi Nakagawa
> >=20
> > Signed-off-by: Hirofumi Nakagawa <hnakagawa@miraclelinux.com>
> > ---
>=20
> Hmm, after thinking a bit I am not sure this is the right way to go.
> Indeed, we try to avoid likly()/unlikely(), unless this is really
> hot-path. Some kernel developers even think these hints should never
> be used. So I'd say, the right thing would bo to remove unlikely()
> from IS_ERR() macro instead.

OK, after some googling I tend to thing having unlikely() in IS_ERR() i=
s
OK, so I take your patch. Thanks.=20

--=20
Best regards,
Artem Bityutskiy (=D0=91=D0=B8=D1=82=D1=8E=D1=86=D0=BA=D0=B8=D0=B9 =D0=90=
=D1=80=D1=82=D1=91=D0=BC)

