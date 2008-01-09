From: Karsten Keil <kkeil@suse.de>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 9 Jan 2008 21:32:06 +0100
Message-ID: <20080109203206.GB26160@pingi.kke.suse.de>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080110.013857.37616214.yoshfuji@linux-ipv6.org> <20080110.014051.121940744.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:49394 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753730AbYAIUcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 15:32:08 -0500
Received: from Relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 9C2F0260BA
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2008 21:32:07 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20080110.014051.121940744.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 01:40:51AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080110.013857.37616214.yoshfuji@linux-ipv6.org> (at Thu=
, 10 Jan 2008 01:38:57 +0900 (JST)), YOSHIFUJI Hideaki / =E5=90=89=E8=97=
=A4=E8=8B=B1=E6=98=8E <yoshfuji@linux-ipv6.org> says:
>=20
> > - we could have "dad_reaction" interface variable and
> >  > 1: disable interface
> >  =3D 1: disable IPv6
> >  < 0: ignore (as we do now)
>=20
> Argh, >0, 0 and <0, maybe.
>=20

I would like this solution, I had something similar to this in mind aft=
er I
discovered the issue.

--=20
Karsten Keil
SuSE Labs
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex,=
 HRB 16746 (AG Nuernberg)
