From: Lucas Nussbaum <lucas@lucas-nussbaum.net>
Subject: Re: e1000e: NIC not working, power management issue?
Date: Thu, 15 Sep 2011 06:48:04 +0200
Message-ID: <20110915044804.GA30817@xanadu.blop.info>
References: <20110914134042.GA5739@xanadu.blop.info>
 <1316032260.6309.1.camel@defected>
 <CALWPMBEvwFbP-G+Ojfr_vM2riwG9vax3_3cQ1SzBR4OmdnHnsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederik Himpe <fhimpe@telenet.be>, netdev@vger.kernel.org,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: John Ronciak <john.ronciak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:50622 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716Ab1IOEvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 00:51:17 -0400
Content-Disposition: inline
In-Reply-To: <CALWPMBEvwFbP-G+Ojfr_vM2riwG9vax3_3cQ1SzBR4OmdnHnsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/09/11 at 14:14 -0700, John Ronciak wrote:
> On Wed, Sep 14, 2011 at 1:31 PM, Frederik Himpe <fhimpe@telenet.be> w=
rote:
>=20
> >>
> >> dmesg:
> >> [ 6260.327320] e1000e: Intel(R) PRO/1000 Network Driver - 1.4.4-k
> >> [ 6260.327324] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> >> [ 6260.327355] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, lo=
w) -> IRQ 22
> >> [ 6260.327366] e1000e 0000:00:19.0: setting latency timer to 64
> >> [ 6260.327490] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
> >> [ 6260.517813] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Wid=
th x1) 00:24:e8:a7:2c:42
> >> [ 6260.517824] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Networ=
k Connection
> >> [ 6260.518077] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: =
3002FF-0FF
> >> [ 6260.518102] e1000e 0000:00:19.0: PME# enabled
> >> [ 6260.556129] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-=
0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
> >> [ 6260.556139] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-=
0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
> >> [ 6260.556147] e1000e 0000:00:19.0: BAR 2: set to [io =A00xefe0-0x=
efff] (PCI address [0xefe0-0xefff])
> >> [ 6260.556167] e1000e 0000:00:19.0: restoring config space at offs=
et 0xf (was 0x100, writing 0x10a)
> >> [ 6260.556193] e1000e 0000:00:19.0: restoring config space at offs=
et 0x1 (was 0x100000, writing 0x100107)
> >> [ 6260.556253] e1000e 0000:00:19.0: PME# disabled
> >> [ 6260.645141] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
> >> [ 6260.700393] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
> >> [ 6260.702222] ADDRCONF(NETDEV_UP): eth0: link is not ready
> It doesn't have link.  Without link nothing can happen on the wire.
> What are you expecting to happen here?
>=20
> Have the device get link first.

What do you mean by "get link" ?
A network cable is plugged in the ethernet port, but it doesn't seem to=
 be
detected in Linux 3.0 (while everything works fine in 2.6.32).

Also, it seems that link is detected when the laptop first boots, until=
 a "MAC
Wakeup cause - Link Status Change" message:
[    1.189506] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1=
) 00:24:e8:a7:2c:42
[    1.189579] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Con=
nection
[    1.189664] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 3002F=
=46-0FF
[   30.636723] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   33.780901] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow =
Control: Rx/Tx
[   33.783944] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[...]
[ 6255.418398] e1000e 0000:00:19.0: eth0: MAC Wakeup cause - Link Statu=
s Change

Lucas
