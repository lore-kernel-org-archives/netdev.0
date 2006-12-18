From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: fix compilation breakage introduced recently.
Date: Mon, 18 Dec 2006 12:04:12 +0300
Message-ID: <20061218090412.GB21778@2ka.mipt.ru>
References: <20061217112946.GA15926@2ka.mipt.ru> <20061217.170958.85671867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: toralf.foerster@gmx.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56699 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563AbWLRJEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 04:04:36 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061217.170958.85671867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 17, 2006 at 05:09:58PM -0800, David Miller (davem@davemloft=
=2Enet) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Sun, 17 Dec 2006 14:29:46 +0300
>=20
> > Linus has changed work queue structure and has not tested it with
> > connector compiled in, his changes break the build.
> >=20
> > Attached patch fixes compilation error.
> >=20
> > Patch is against commit 99f5e9718185f07458ae70c2282c2153a2256c91.
> >=20
> > Thanks to Toralf F=C3=B6rster for pointing this out.
> >=20
> > Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>=20
> Applied, thanks Evgeniy.

Thanks.
I will send a patch on top of this to replace delayed work with usual w=
ork
queue today.

--=20
	Evgeniy Polyakov
