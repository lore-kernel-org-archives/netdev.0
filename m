From: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 00/16] net: remove unnecessary break after goto/return
Date: Mon, 14 Jul 2014 18:30:50 +0200
Message-ID: <1405355467-7350-1-git-send-email-fabf@skynet.be>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tipc-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Small patchset addressing break redundancy on net branch
(suggested by Joe Perches).

Fabian Frederick (16):
  packet: remove unnecessary break after return
  tipc: remove unnecessary break after return
  9P: remove unnecessary break after return
  af_iucv: remove unnecessary break after goto
  netlabel: remove unnecessary break after goto
  pktgen: remove unnecessary break after goto
  drop_monitor: remove unnecessary break after return
  mac80211: remove unnecessary break after return
  af_key: remove unnecessary break after return
  netfilter: remove unnecessary break after return
  ipv6: remove unnecessary break after return
  NFC: remove unnecessary break after goto
  caif: remove unnecessary break after goto
  irda: remove unnecessary break after return
  ieee802154: remove unnecessary break after goto
  net: sctp: remove unnecessary break after return/goto

 net/9p/client.c                      | 1 -
 net/caif/cfctrl.c                    | 1 -
 net/core/drop_monitor.c              | 2 --
 net/core/pktgen.c                    | 1 -
 net/ieee802154/6lowpan_iphc.c        | 1 -
 net/ipv6/ipv6_sockglue.c             | 1 -
 net/ipv6/netfilter/ip6t_ipv6header.c | 1 -
 net/irda/af_irda.c                   | 1 -
 net/irda/irlan/irlan_common.c        | 1 -
 net/iucv/af_iucv.c                   | 1 -
 net/key/af_key.c                     | 3 ---
 net/mac80211/mesh_hwmp.c             | 1 -
 net/netlabel/netlabel_kapi.c         | 1 -
 net/nfc/digital_dep.c                | 2 --
 net/packet/af_packet.c               | 2 --
 net/sctp/outqueue.c                  | 1 -
 net/sctp/sm_statefuns.c              | 4 ----
 net/tipc/socket.c                    | 1 -
 18 files changed, 26 deletions(-)

-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
