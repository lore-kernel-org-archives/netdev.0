From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH for v3.15] net: mvmdio: Check for a valid interrupt
 instead of an error
Date: Wed, 30 Apr 2014 13:21:01 -0300
Message-ID: <20140430162101.GA18300@arch.cereza>
References: <1398800999-9814-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <53601B96.3000608@gmail.com>
 <20140430114209.GA1907@arch.cereza>
 <5360FA35.7070209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:48087 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759165AbaD3QVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:21:35 -0400
Content-Disposition: inline
In-Reply-To: <5360FA35.7070209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Apr 30, Sebastian Hesselbarth wrote:
> >
> >Yes, I agree. Did another patch for that, but haven't send it yet.
> >AFAICS, mvebu platforms will never hit the deferred case as the irqc=
hip
> >is the first driver registered (as per drivers/Makefile).
> >
> >Not that we should count on that :)
>=20
> It doesn't hit it _now_ because of the above. I read about proper
> platform_device for early devices here and there over and over
> again, so I guess some day it may become an issue.
>=20
> As we know about the potential -EPROBE_DEFER now, I suggest to
> deal with it now, too.
>=20
> Can you resend this as v2 with the other patch you mentioned
> squashed in?
>=20

Oh! I've just remembered why I didn't send the EPROBE_DEFER patch in th=
e first
place. The mvneta driver connects to the phy at open()-time, in a funct=
ion
called "mvneta_mdio_probe()". This name confused me to think the mdio w=
as
really probed at open()-time.

I guess it was very late at night when I came to such conclusion :)
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
