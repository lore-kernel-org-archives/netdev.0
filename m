From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [PATCH 1/2] Remove REDWOOD_[456] config options and
 conditional code
Date: Sun, 18 Jul 2010 19:52:31 +0300
Message-ID: <1279471951.16247.61.camel@localhost.localdomain>
References: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
	 <redwood56-reply-1-miltonm@bga.com>
	 <cover.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	 <ca1bb25d203618c3548748f5efb6f125a96c89e0.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	 <20100716142055.GA11736@zod.rchland.ibm.com>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>,
	Milton Miller <miltonm@bga.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Solomon Peachy <solomon@linux-wlan.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Artem Bityutskiy <Artem.Bityutskiy@nokia.com>,
	Alexander Kurz <linux@kbdbabel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Florian Fainelli <florian@openwrt.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	Joe Perches <joe@perches.com>,
	Ladislav Michl <ladis@linux-mips.org>,
	David Brown <davidb@quicinc.com>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org, vamos-dev@i4.info
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52553 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756685Ab0GRQwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 12:52:41 -0400
In-Reply-To: <20100716142055.GA11736@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-16 at 10:20 -0400, Josh Boyer wrote:
> On Fri, Jul 16, 2010 at 02:29:02PM +0200, Christian Dietrich wrote:
> >The config options for REDWOOD_[456] were commented out in the power=
pc
> >Kconfig. The ifdefs referencing this options therefore are dead and =
all
> >references to this can be removed (Also dependencies in other KConfi=
g
> >files).
> >
> >Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erla=
ngen.de>
> >Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
>=20
> This seems fine with me.
>=20
> The only question is which tree it coms through.  I'm happy to take i=
t
> in via mine if the netdev and MTD people are fine with that.  Otherwi=
se,
> my ack is below.
>=20
> Acked-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

You know how slow MTD people may be sometimes, so I'd suggest you to
merge this via whatever tree. David is in CC, he'll complain if he is
unhappy, I think.

--=20
Best Regards,
Artem Bityutskiy (=D0=90=D1=80=D1=82=D1=91=D0=BC =D0=91=D0=B8=D1=82=D1=8E=
=D1=86=D0=BA=D0=B8=D0=B9)

