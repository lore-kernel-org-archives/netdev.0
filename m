From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 0/7] genetlink: reduce ops size and complexity
Date: Thu, 14 Nov 2013 15:36:09 +0100
Message-ID: <1384439769.13941.26.camel@jlt4.sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:48749 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab3KNOgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:36:15 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Vgy1j-0006e7-I2
	for netdev@vger.kernel.org; Thu, 14 Nov 2013 15:36:11 +0100
In-Reply-To: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 10:14 +0100, Johannes Berg wrote:
> This series of patches updates a few genetlink users and then
> makes the ops a static const array, reducing kernel size and
> code complexity.

FWIW, for the full series (including patches 8 and 9) we get

 drivers/net/team/team.c               |    2 
 drivers/net/wireless/mac80211_hwsim.c |    2 
 include/net/genetlink.h               |   17 +---
 kernel/taskstats.c                    |   39 +++------
 net/core/drop_monitor.c               |    2 
 net/hsr/hsr_netlink.c                 |   46 ++++-------
 net/ieee802154/ieee802154.h           |   19 ++++
 net/ieee802154/netlink.c              |   28 +++++--
 net/ieee802154/nl-mac.c               |   61 ++-------------
 net/ieee802154/nl-phy.c               |   37 +--------
 net/ipv4/tcp_metrics.c                |    2 
 net/irda/irnetlink.c                  |    2 
 net/l2tp/l2tp_netlink.c               |    2 
 net/netfilter/ipvs/ip_vs_ctl.c        |    2 
 net/netlabel/netlabel_cipso_v4.c      |    2 
 net/netlabel/netlabel_mgmt.c          |    2 
 net/netlabel/netlabel_unlabeled.c     |    2 
 net/netlink/genetlink.c               |  133
+++++++++-------------------------
 net/nfc/netlink.c                     |    2 
 net/openvswitch/datapath.c            |   10 +-
 net/wimax/op-msg.c                    |   25 ------
 net/wimax/op-reset.c                  |   17 ----
 net/wimax/op-rfkill.c                 |   21 -----
 net/wimax/op-state-get.c              |   17 ----
 net/wimax/stack.c                     |   79 ++++++++++----------
 net/wimax/wimax-internal.h            |    7 +
 net/wireless/nl80211.c                |    2 
 27 files changed, 190 insertions(+), 390 deletions(-)

johannes
