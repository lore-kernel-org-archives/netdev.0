From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 37/42] synclink: convert devices to new API (rev2)
Date: Thu, 08 Jan 2009 23:49:37 +0100
Message-ID: <m3y6xljtvi.fsf@maximus.localdomain>
References: <20090107003316.784424362@vyatta.com>
	<20090107003349.468715485@vyatta.com>
	<20090107154835.37f4de4c@extreme>
	<20090107.180802.118061961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46770 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761204AbZAHWtj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 17:49:39 -0500
In-Reply-To: <20090107.180802.118061961.davem@davemloft.net> (David Miller's message of "Wed\, 07 Jan 2009 18\:08\:02 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> I'm deferring this while you and Krzysztof work out how
> to implement this properly.

It seems it's ready. Tested with IXP4xx HSS against i686 + PCI200SYN.
X.25 not tested, as usual, but the remaining protocols seem to work.

I'll append the concatenated patch as well.

The following changes since commit 56cf391a9462a4897ea660a6af3662dda5ae8c84:
  Inaky Perez-Gonzalez (1):
        wimax: fix kernel-doc for debufs_dentry member of struct wimax_dev

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-david

me:
      WAN: Generic HDLC now uses IFF_WAN_HDLC private flag.
      WAN: Allow hw HDLC drivers to override dev->get_stats.
      Fix a comment in include/linux/netdevice.h.
      WAN: Convert generic HDLC drivers to netdev_ops.
      WAN: Fix NAPI interface in IXP4xx HSS driver.

 drivers/char/pcmcia/synclink_cs.c |   18 +++++++++++-------
 drivers/char/synclink.c           |   18 +++++++++++-------
 drivers/char/synclink_gt.c        |   18 +++++++++++-------
 drivers/char/synclinkmp.c         |   18 +++++++++++-------
 drivers/net/wan/c101.c            |   12 ++++++++----
 drivers/net/wan/cosa.c            |   14 ++++++++++----
 drivers/net/wan/dscc4.c           |   18 +++++++++++-------
 drivers/net/wan/farsync.c         |   18 ++++++++++++------
 drivers/net/wan/hdlc.c            |   29 ++++++++++++++---------------
 drivers/net/wan/hdlc_cisco.c      |    1 -
 drivers/net/wan/hdlc_fr.c         |   28 +++++++++-------------------
 drivers/net/wan/hdlc_ppp.c        |    2 --
 drivers/net/wan/hdlc_raw.c        |    3 ---
 drivers/net/wan/hdlc_raw_eth.c    |    8 ++------
 drivers/net/wan/hdlc_x25.c        |    2 +-
 drivers/net/wan/hostess_sv11.c    |   12 +++++++++---
 drivers/net/wan/ixp4xx_hss.c      |   18 ++++++++++++------
 drivers/net/wan/lmc/lmc_main.c    |   19 +++++++++++--------
 drivers/net/wan/lmc/lmc_proto.c   |   17 +----------------
 drivers/net/wan/n2.c              |   12 ++++++++----
 drivers/net/wan/pc300too.c        |   12 ++++++++----
 drivers/net/wan/pci200syn.c       |   12 ++++++++----
 drivers/net/wan/sealevel.c        |   12 +++++++++---
 drivers/net/wan/wanxl.c           |   14 ++++++++++----
 include/linux/hdlc.h              |    5 +++++
 include/linux/if.h                |    1 +
 include/linux/netdevice.h         |    2 +-
 27 files changed, 194 insertions(+), 149 deletions(-)
-- 
Krzysztof Halasa
