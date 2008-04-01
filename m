From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 0 of 5] IPv6: Fix temporary address support
Date: Tue, 1 Apr 2008 23:55:18 +0200
Message-ID: <20080401215518.GO475@pirzuine>
References: <20080327175839.GB8574@ens-lyon.fr> <20080328.031240.97295681.yoshfuji@linux-ipv6.org> <20080328003221.GE8574@ens-lyon.fr> <20080328.121540.18727107.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, pekkas@netcore.fi, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:45835 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbYDAVzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 17:55:20 -0400
Content-Disposition: inline
In-Reply-To: <20080328.121540.18727107.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 12:15:40PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080328003221.GE8574@ens-lyon.fr> (at Fri, 28 Mar 2008 0=
1:32:21 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
>=20
> > Do you have an opinion about my PS (DESYNC_FACTOR not being random)=
 ?
>=20
> Oh, that's a bug ...

Ok. What is the best way to generate a random number ? get_random_bytes
and modulo ? (the distribution won't be ok, but I guess it's not really
a problem for this case).

> and, max_desync_factor is not effective.

what do you mean by that ?

regards,

Benoit
--=20
:wq
