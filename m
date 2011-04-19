From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 14:39:00 +0100
Message-ID: <1303220340.5997.197.camel@zakaz.uk.xensource.com>
References: <20110419115612.C4ACA13909@rere.qmqm.pl>
	 <1303219073.5997.191.camel@zakaz.uk.xensource.com>
	 <20110419133019.GA3973@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:34916 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab1DSNjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 09:39:02 -0400
In-Reply-To: <20110419133019.GA3973@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 14:30 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, Apr 19, 2011 at 02:17:53PM +0100, Ian Campbell wrote:
> > On Tue, 2011-04-19 at 12:56 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > Thanks for beating me to this! However the prototype for
> > xenvif_fix_features is wrong (needs to take a net_device not a xenv=
if).
>=20
> I'll resend v2 with this fix.
>=20
> > I fixed it with the following, I also moved the !can_sg MTU clampin=
g
> > into a set_features hook (like we do with netfront). Am I right tha=
t
> > this pattern copes with changes to SG via ethtool etc better? I thi=
nk
> > it's more future proof in any case.
>=20
> This looks wrong. Even if SG is turned on, you might get big skbs whi=
ch
> are linearized. There is a difference in SG capability and SG offload
> status and as I see it the capability is what you need to test for MT=
U.

So the existing stuff in drivers/net/xen-netfront.c is wrong too?

> > NB: I'm having some issues with my test hardware at the moment so t=
his
> > is reviewed by eye and compile tested only...
> >=20
> > I'm also happy for this to be folded into the original with my
> > "Signed-off-/Acked-by Ian Campbell <ian.campbell@citrix.com>" if th=
at is
> > preferable.
>=20
> Thanks.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw


