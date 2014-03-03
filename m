From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [net-next v4 0/3] 802.21 and MPLS headers and classification
Date: Mon,  3 Mar 2014 17:23:09 +0100
Message-ID: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de,
	Simon Wunderlich <sw@simonwunderlich.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55032 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888AbaCCQXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 11:23:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this series contains a header file proposal for MPLS labels. These
labels do not seem to be properly defined in the kernel so far. We are
developing a wired/wireless 802.21/MPLS switch and need to check the
MPLS labels to use the traffic control info for transmissions over
802.11 networks.

Changes to third version:

 * rename mpls_label_stack to mpls_label (thanks Neil)
 * fix over-indendented closing brac (thanks Sergei)
 * add Johannes' Ack

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
