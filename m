From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Mon, 14 Jun 2010 22:03:09 +0200
Message-ID: <1276545789.2444.33.camel@edumazet-laptop>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <1276466190.14011.223.camel@localhost>
	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
	 <4C1662C3.3070708@trash.net>  <1276544573.4897.6.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>,
	Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:54892 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab0FNUDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 16:03:13 -0400
Received: by wwb18 with SMTP id 18so4205508wwb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 13:03:11 -0700 (PDT)
In-Reply-To: <1276544573.4897.6.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 12:42 -0700, Joe Perches a =C3=A9crit :
> On Mon, 2010-06-14 at 19:11 +0200, Patrick McHardy wrote:

> > Additionally:
> > - the pr_debug statements may be useful for debugging, but are
> >   a bit excessive for the final version
>=20
> Patrick, what's wrong with pr_debug?
> Do you prefer pr_devel?

In the patch context, this pr_debug() is not necessary.

Just remove it, since its a normal situation, no need to log anything,
ever.



