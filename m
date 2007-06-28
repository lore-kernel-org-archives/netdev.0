From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Thu, 28 Jun 2007 19:00:27 +0200
Message-ID: <4683E92B.7000600@trash.net>
References: <20070628162056.18728.20195.stgit@localhost.localdomain> <20070628162113.18728.20109.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55079 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759993AbXF1RBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 13:01:24 -0400
In-Reply-To: <20070628162113.18728.20109.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
>  include/linux/etherdevice.h |    3 +-
>  include/linux/netdevice.h   |   62 ++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/skbuff.h      |    4 ++-
>  net/core/dev.c              |   27 +++++++++++++------
>  net/core/netpoll.c          |    8 +++---
>  net/core/pktgen.c           |   10 +++++--
>  net/core/skbuff.c           |    3 ++
>  net/ethernet/eth.c          |    9 +++---
>  8 files changed, 104 insertions(+), 22 deletions(-)

> include/linux/pkt_sched.h |    9 +++
> net/sched/Kconfig         |   23 +++++++
> net/sched/sch_prio.c      |  147
+++++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 166 insertions(+), 13 deletions(-)


Quick question: where are the sch_generic changes? :)

If you hold for ten minutes I'll post a set of slightly changed
patches with the NETDEVICES_MULTIQUEUE option and a fix for this.
