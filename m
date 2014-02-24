From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [net-next v3 0/3] 802.21 and MPLS headers and classification
Date: Mon, 24 Feb 2014 13:28:37 +0100
Message-ID: <1393244920-15903-1-git-send-email-sw@simonwunderlich.de>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de,
	Simon Wunderlich <sw@simonwunderlich.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:41607 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbaBXM2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 07:28:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series contains a header file proposal for MPLS labels. These
labels do not seem to be properly defined in the kernel so far. We are
developing a wired/wireless 802.21/MPLS switch and need to check the
MPLS labels to use the traffic control info for transmissions over
802.11 networks.

The first patches are resent without changes. The third patch was
changed to use skb->protocol instead of checking the ethernet type to
determine if MPLS was used, as suggested by David Miller.

Thanks,
     Simon

Simon Wunderlich (3):
  if_ether.h: add IEEE 802.21 Ethertype
  UAPI: add MPLS label stack definition
  cfg80211: add MPLS and 802.21 classification

 include/linux/mpls.h          |    6 ++++++
 include/uapi/linux/if_ether.h |    1 +
 include/uapi/linux/mpls.h     |   34 ++++++++++++++++++++++++++++++++++
 net/wireless/util.c           |   16 ++++++++++++++++
 4 files changed, 57 insertions(+)
 create mode 100644 include/linux/mpls.h
 create mode 100644 include/uapi/linux/mpls.h

-- 
1.7.10.4
