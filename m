From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PULL REQ] WAN: LMC driver
Date: Sat, 31 Jul 2010 16:36:36 +0200
Message-ID: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39600 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab0GaOgj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 10:36:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

I have done a bit of work on the LMC WAN driver. It's still far from
perfection, though I think it's a visible improvement. It merges with
your current "next" tree cleanly. I'll also post the individual patches=
=2E
Please pull. Thanks.

The following changes since Linux 2.6.35-rc6 are available in the git
repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git lmc

Krzysztof Ha=C5=82asa (29):
      LMC: whitespace and cosmetic fixes.
      LMC: Remove "lmc_" prefix from source file names.
      LMC: Remove 3 typedefs.
      LMC: fix initialization messages.
      LMC: Remove non-LMC_PPP modes, everything is already handled by g=
eneric HDLC.
      LMC: Remove stub files proto.[ch].
      LMC: Convert media structs to named initializers.
      LMC: Remove "dummy" media functions.
      LMC: shuffle protocol routines to avoid a need for prototypes.
      LMC: Remove empty media functions.
      LMC: Get rid of lmcConsoleLog().
      LMC: Get rid of the event logger.
      LMC: Get rid of debug.[ch].
      LMC: Remove now empty header file lmc.h.
      LMC: lanmedia.com is not functional anymore.
      LMC: Remove unused macros.
      LMC: don't wait in lmc_trace().
      LMC: strip "lmc_" prefix from field names in struct card.
      LMC: Remove sc->check. We don't do such checks in drivers.
      LMC: Remove unused sc->board_idx.
      LMC: I'm sure Linux doesn't swap PCI subsystem device and vendor =
IDs.
      LMC: Move model logic to media structs.
      LMC: lmc_set_protocol() is effectively a NOP, remove it.
      LMC: Remove unused variables.
      LMC: Remove unneeded prototypes.
      LMC: Remove redundant macro.
      LMC: Remove redundant card->name.
      LMC: Simplify and fix CSR names and logic.
      LMC: Report proper card type before the first dev->open().

 drivers/net/wan/lmc/Makefile    |    4 +-
 drivers/net/wan/lmc/ioctl.h     |  228 +++++
 drivers/net/wan/lmc/lmc.h       |   32 -
 drivers/net/wan/lmc/lmc_debug.c |   82 --
 drivers/net/wan/lmc/lmc_debug.h |   52 -
 drivers/net/wan/lmc/lmc_ioctl.h |  257 -----
 drivers/net/wan/lmc/lmc_main.c  | 2145 -------------------------------=
--------
 drivers/net/wan/lmc/lmc_media.c | 1211 ----------------------
 drivers/net/wan/lmc/lmc_proto.c |  135 ---
 drivers/net/wan/lmc/lmc_proto.h |   18 -
 drivers/net/wan/lmc/lmc_var.h   |  470 ---------
 drivers/net/wan/lmc/main.c      | 1834 +++++++++++++++++++++++++++++++=
++
 drivers/net/wan/lmc/media.c     |  944 +++++++++++++++++
 drivers/net/wan/lmc/var.h       |  423 ++++++++
 14 files changed, 3431 insertions(+), 4404 deletions(-)
 create mode 100644 drivers/net/wan/lmc/ioctl.h
 delete mode 100644 drivers/net/wan/lmc/lmc.h
 delete mode 100644 drivers/net/wan/lmc/lmc_debug.c
 delete mode 100644 drivers/net/wan/lmc/lmc_debug.h
 delete mode 100644 drivers/net/wan/lmc/lmc_ioctl.h
 delete mode 100644 drivers/net/wan/lmc/lmc_main.c
 delete mode 100644 drivers/net/wan/lmc/lmc_media.c
 delete mode 100644 drivers/net/wan/lmc/lmc_proto.c
 delete mode 100644 drivers/net/wan/lmc/lmc_proto.h
 delete mode 100644 drivers/net/wan/lmc/lmc_var.h
 create mode 100644 drivers/net/wan/lmc/main.c
 create mode 100644 drivers/net/wan/lmc/media.c
 create mode 100644 drivers/net/wan/lmc/var.h

--=20
Krzysztof Halasa
