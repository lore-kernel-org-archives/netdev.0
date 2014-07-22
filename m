From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: mvebu: Can we make the orion-mdio clock a requirement?
Date: Tue, 22 Jul 2014 20:46:53 -0300
Message-ID: <20140722234653.GB21545@arch.cereza>
References: <20140721190614.GB20027@arch.cereza>
 <20140721212818.2d4920c4@free-electrons.com>
 <53CD743D.9080700@gmail.com>
 <20140721222326.668db913@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:37334 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752821AbaGVXrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 19:47:52 -0400
Content-Disposition: inline
In-Reply-To: <20140721222326.668db913@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 Jul 10:23 PM, Thomas Petazzoni wrote:
> On Mon, 21 Jul 2014 22:12:45 +0200, Sebastian Hesselbarth wrote:
>=20
> > > However, yes, I tend to agree, making the clock mandatory would
> > > probably be a good thing.
> >=20
> > We can always pass TCLK on Orion5x if there is a need for a mandato=
ry
> > clock. Anyway, IIRC clock framework should now properly return
> > -EPROPEDEFER only if there is a clock property set. If there is non=
e,
> > the error is different and can be catched on Orion5x.
>=20
> Yes, I already use tclk on Orion5x for various clock references.
>=20

Since we all agree, I'll prepare a patchset changing the mvmdio devicet=
ree
binding so the clock is required.

On the driver side, we can only print a warning if the clock is missing=
,
to keep compatibility.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
