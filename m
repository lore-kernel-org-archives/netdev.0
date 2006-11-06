From: David Miller <davem@davemloft.net>
Subject: Re: linux-2.6.19-rc4-g10b1fbdb build #114 failed
Date: Sun, 05 Nov 2006 16:45:18 -0800 (PST)
Message-ID: <20061105.164518.104646198.davem@davemloft.net>
References: <200611051943.27210.toralf.foerster@gmx.de>
	<Pine.LNX.4.64.0611051621450.30121@sockpuppet.zko.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: toralf.foerster@gmx.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2491
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422910AbWKFApU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Nov 2006 19:45:20 -0500
To: paul.moore@hp.com
In-Reply-To: <Pine.LNX.4.64.0611051621450.30121@sockpuppet.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Paul Moore <paul.moore@hp.com>
Date: Sun, 5 Nov 2006 16:24:07 -0500 (EST)

> On Sun, 5 Nov 2006, Toralf F=F6rster wrote:
> >
> > Hello,
> >
> > the build with the attached .config failed, make ends with:
> > ...
> > : undefined reference to `cipso_v4_sock_getattr'
> > net/built-in.o: In function `netlbl_socket_getattr':
>=20
> Ah ha!  Why did you have to go and build a kernel without TCP/IP
> networking ;)
>=20
> It looks like I was stupid and made NetLabel depend on CONFIG_NET and=
 not
> CONFIG_INET, the patch below should fix this by making NetLabel depen=
d on
> CONFIG_INET and CONFIG_SECURITY.  Please review and apply for 2.6.19.
>=20
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, thanks Paul.

What email client are you using?  There were a bunch of spacing
issues I had to correct in your patch before it would apply
cleanly.  (1) lines with only spaces were changed to empty lines
(2) Severl lines had an extra space added to the beginning.
