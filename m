From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [net-next v2 0/3] 802.21 and MPLS headers and classification
Date: Mon, 17 Feb 2014 17:56:10 +0100
Message-ID: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org,
	Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this series contains a header file proposal for MPLS labels. These
labels do not seem to be properly defined in the kernel so far. We are
developing a wired/wireless 802.21/MPLS switch and need to check the
MPLS labels to use the traffic control info for transmissions over
802.11 networks.

Thanks to Joe Perches for comments - changes have been made according
to his suggestions, check the individual patches for details.

Thanks,
     Simon

Simon Wunderlich (3):
  if_ether.h: add IEEE 802.21 Ethertype
  UAPI: add MPLS label stack definition
  cfg80211: add MPLS and 802.21 classification

 include/linux/mpls.h          |    6 ++++++
 include/uapi/linux/if_ether.h |    1 +
 include/uapi/linux/mpls.h     |   34 ++++++++++++++++++++++++++++++++++
 net/wireless/util.c           |   24 ++++++++++++++++++++++++
 4 files changed, 65 insertions(+)
 create mode 100644 include/linux/mpls.h
 create mode 100644 include/uapi/linux/mpls.h

-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
