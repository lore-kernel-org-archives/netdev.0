From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: make skb_truesize_bug() call WARN()
Date: Tue, 25 Nov 2008 18:02:19 +0000
Message-ID: <1227636139.3109.11.camel@achroite>
References: <20081125083250.2ad7d75d@infradead.org>
	 <1227631323.3109.7.camel@achroite>  <20081125095432.04d73b01@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:37145 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752266AbYKYSC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 13:02:26 -0500
In-Reply-To: <20081125095432.04d73b01@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-11-25 at 09:54 -0800, Arjan van de Ven wrote:
> On Tue, 25 Nov 2008 16:42:03 +0000
> Ben Hutchings <bhutchings@solarflare.com> wrote:
>=20
> > On Tue, 2008-11-25 at 08:32 -0800, Arjan van de Ven wrote:
> > > From 97a8ab520c378568e172c555a156b469137a3828 Mon Sep 17 00:00:00
> > > 2001 From: Arjan van de Ven <arjan@linux.intel.com>
> > > Date: Tue, 25 Nov 2008 08:30:04 -0800
> > > Subject: [PATCH] net: make skb_truesize_bug() call WARN()
> > >=20
> > > The truesize message check is important enough to make it print
> > > "BUG" to the user console... lets also make it important enough t=
o
> > > spit a backtrace/module list etc so that kerneloops.org can track
> > > them.
[...]
> > =EF=BB=BFThe bug reports I've seen (with my Debian hat on, not rela=
ting to
> > sfc) show that configurations that trigger this warning are likely =
to
> > trigger many times over and there's nothing the user can do about
> > it.  So by all means do make the warning more obvious, but please
> > make it WARN_ON_ONCE and then use printk qualified by net_ratelimit=
().
> >=20
>=20
> if there's no value in those subsequent printk's.. why not just this?
[...]

I think there may be some value in them: users who want to help debug
this can experiment to see which configurations or traffic types do or
don't result in invalid truesize.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

