From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Regarding tx-nocache-copy in the Sheevaplug
Date: Mon, 13 Oct 2014 12:52:46 +0200
Message-ID: <20141013105246.GD1972@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

on the 7th of January 2014 ths patch was applied:
https://lkml.org/lkml/2014/1/7/307

[PATCH v2] net: Do not enable tx-nocache-copy by default
       =20
In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made packets=
 to be
sent corrupted. I think this machine has something special about the ca=
che.

Enabling back this tx-nocache-copy (as it used to be before the patch) =
the
transfers work fine again. I think that most people, encountering this =
problem,
completely disable the tx offload instead of enabling back this setting=
=2E

Is this an ARM kernel problem regarding this platform?

Thank you,
Llu=EDs
