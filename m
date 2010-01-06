From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC] PCMCIA patches for 2.6.34
Date: Wed, 6 Jan 2010 12:45:31 +0100
Message-ID: <20100106114531.GA29913@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-pcmcia@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:47059 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754819Ab0AFLrI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 06:47:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

here are some patches relating to the PCMCIA subsystem, and intended for
2.6.34. I'm interested in your input to this patch series. They'll be
sent to the PCMCIA list shortly, with CC to other lists if deemed
appropriate.

      pcmcia: make use of pcmcia_dev_resume() return value
      pcmcia: remove remaining unused IRQ_FIRST_SHARED parameter
      pcmcia: do not meddle with already assigned resources
      pcmcia: validate CIS, not CIS cache.
      pcmcia: cleanup pccard_validate_cis()
      pcmcia: improve check for same card in slot after resume
      pcmcia: CardBus doesn't need CIS access
      pcmcia: call CIS cleanup from ds.c
      pcmcia: rsrc_nonstatic io memory probe improvements
      pcmcia: do not lock socket driver module in pcmcia_get_socket()
      pcmcia: do not lock socket driver module on card insert
      pcmcia: remove useless indirection
      pcmcia: remove some rsrc_mgr indirections
      pcmcia: m32r uses static socket resources
      pcmcia: m8xx_pcmcia.c should use iodyn resource manager

 drivers/net/pcmcia/smc91c92_cs.c |    6 +-
 drivers/pcmcia/Kconfig           |    3 -
 drivers/pcmcia/cardbus.c         |  175 ++-----------------
 drivers/pcmcia/cistpl.c          |  368 +++++++++++++-------------------------
 drivers/pcmcia/cs.c              |   89 +++++-----
 drivers/pcmcia/cs_internal.h     |   25 ---
 drivers/pcmcia/ds.c              |   25 +++-
 drivers/pcmcia/m32r_cfc.c        |    2 +-
 drivers/pcmcia/m8xx_pcmcia.c     |    2 +-
 drivers/pcmcia/pcmcia_resource.c |   17 ++
 drivers/pcmcia/rsrc_mgr.c        |   24 ---
 drivers/pcmcia/rsrc_nonstatic.c  |  184 ++++++++++++-------
 include/pcmcia/ss.h              |    9 +-
 13 files changed, 341 insertions(+), 588 deletions(-)

Best,
	Dominik
