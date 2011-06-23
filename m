From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: use pci_dev->revision
Date: Thu, 23 Jun 2011 17:32:04 +0200
Message-ID: <20110623173204.00fbaed6@maggie>
References: <201106231849.53030.sshtylyov@ru.mvista.com>
	<20110623170908.1417f933@maggie>
	<4E0357BF.7000408@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:55841 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759615Ab1FWPcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 11:32:13 -0400
In-Reply-To: <4E0357BF.7000408@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011 19:11:59 +0400
Sergei Shtylyov <sshtylyov@mvista.com> wrote:

> Hello.
>=20
> Michael B=C3=BCsch wrote:
>=20
> >> The bus scan code reads PCI revision ID from the PCI configuration=
 register
> >> while it's already stored by PCI subsystem in the 'revision' field=
 of 'struct
> >> pci_dev'...
>=20
> >> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
>=20
> >> ---
> >> The patch is against the recent Linus' tree.
>=20
> >> There's another place where the revision ID register is read but a=
s 16-bit
> >> entity (probably by mistake though), so I didn't convert it...
>=20
> > Where is that?
>=20
>     drivers/ssb/pci.c, line 741.

Yes that probably is by mistake. Can you convert it as well, please?
