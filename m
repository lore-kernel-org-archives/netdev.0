From: David Howells <dhowells@redhat.com>
Subject: [GIT PULL] Disintegrate UAPI for net
Date: Tue, 09 Oct 2012 14:30:33 +0100
Message-ID: <30725.1349789433@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can you merge the following branch into the net tree please.

This is to complete part of the Userspace API (UAPI) disintegration for which
the preparatory patches were pulled recently.  After these patches, userspace
headers will be segregated into:

	include/uapi/linux/.../foo.h

for the userspace interface stuff, and:

	include/linux/.../foo.h

for the strictly kernel internal stuff.

---
The following changes since commit 9e2d8656f5e8aa214e66b462680cf86b210b74a8:

  Merge branch 'akpm' (Andrew's patch-bomb) (2012-10-09 16:23:15 +0900)

are available in the git repository at:


  git://git.infradead.org/users/dhowells/linux-headers.git tags/disintegrate-net-20121009

for you to fetch changes up to b6bf56c6be2be7ccebebfd91b1f11889296cbd9e:

  UAPI: (Scripted) Disintegrate include/linux/tc_ematch (2012-10-09 09:49:06 +0100)

----------------------------------------------------------------
UAPI Disintegration 2012-10-09

----------------------------------------------------------------
David Howells (9):
      UAPI: (Scripted) Disintegrate include/linux/caif
      UAPI: (Scripted) Disintegrate include/linux/netfilter
      UAPI: (Scripted) Disintegrate include/linux/netfilter/ipset
      UAPI: (Scripted) Disintegrate include/linux/netfilter_arp
      UAPI: (Scripted) Disintegrate include/linux/netfilter_bridge
      UAPI: (Scripted) Disintegrate include/linux/netfilter_ipv4
      UAPI: (Scripted) Disintegrate include/linux/netfilter_ipv6
      UAPI: (Scripted) Disintegrate include/linux/tc_act
      UAPI: (Scripted) Disintegrate include/linux/tc_ematch

 include/linux/caif/Kbuild                          |   2 -
 include/linux/netfilter/Kbuild                     |  77 ------
 include/linux/netfilter/ipset/Kbuild               |   4 -
 include/linux/netfilter/ipset/ip_set.h             | 225 +----------------
 include/linux/netfilter/ipset/ip_set_bitmap.h      |  11 +-
 include/linux/netfilter/ipset/ip_set_hash.h        |  19 +-
 include/linux/netfilter/ipset/ip_set_list.h        |  19 +-
 include/linux/netfilter/nf_conntrack_common.h      | 115 +--------
 include/linux/netfilter/nf_conntrack_ftp.h         |  16 +-
 include/linux/netfilter/nf_conntrack_tcp.h         |  49 +---
 include/linux/netfilter/nfnetlink.h                |  55 +----
 include/linux/netfilter/nfnetlink_acct.h           |  25 +-
 include/linux/netfilter/x_tables.h                 | 186 +-------------
 include/linux/netfilter/xt_hashlimit.h             |  71 +-----
 include/linux/netfilter/xt_physdev.h               |  21 +-
 include/linux/netfilter_arp/Kbuild                 |   2 -
 include/linux/netfilter_arp/arp_tables.h           | 200 +--------------
 include/linux/netfilter_bridge/Kbuild              |  18 --
 include/linux/netfilter_bridge/ebt_802_3.h         |  61 +----
 include/linux/netfilter_bridge/ebtables.h          | 255 +-------------------
 include/linux/netfilter_ipv4/Kbuild                |  10 -
 include/linux/netfilter_ipv4/ip_tables.h           | 218 +----------------
 include/linux/netfilter_ipv6/Kbuild                |  12 -
 include/linux/netfilter_ipv6/ip6_tables.h          | 256 +-------------------
 include/linux/tc_act/Kbuild                        |   7 -
 include/linux/tc_ematch/Kbuild                     |   4 -
 include/uapi/linux/caif/Kbuild                     |   2 +
 include/{ => uapi}/linux/caif/caif_socket.h        |   0
 include/{ => uapi}/linux/caif/if_caif.h            |   0
 include/uapi/linux/netfilter/Kbuild                |  76 ++++++
 include/uapi/linux/netfilter/ipset/Kbuild          |   4 +
 include/uapi/linux/netfilter/ipset/ip_set.h        | 231 ++++++++++++++++++
 include/uapi/linux/netfilter/ipset/ip_set_bitmap.h |  13 +
 include/uapi/linux/netfilter/ipset/ip_set_hash.h   |  21 ++
 include/uapi/linux/netfilter/ipset/ip_set_list.h   |  21 ++
 include/uapi/linux/netfilter/nf_conntrack_common.h | 117 +++++++++
 include/uapi/linux/netfilter/nf_conntrack_ftp.h    |  18 ++
 .../{ => uapi}/linux/netfilter/nf_conntrack_sctp.h |   0
 include/uapi/linux/netfilter/nf_conntrack_tcp.h    |  51 ++++
 .../linux/netfilter/nf_conntrack_tuple_common.h    |   0
 include/{ => uapi}/linux/netfilter/nf_nat.h        |   0
 include/uapi/linux/netfilter/nfnetlink.h           |  56 +++++
 include/uapi/linux/netfilter/nfnetlink_acct.h      |  27 +++
 .../{ => uapi}/linux/netfilter/nfnetlink_compat.h  |   0
 .../linux/netfilter/nfnetlink_conntrack.h          |   0
 .../linux/netfilter/nfnetlink_cthelper.h           |   0
 .../linux/netfilter/nfnetlink_cttimeout.h          |   0
 include/{ => uapi}/linux/netfilter/nfnetlink_log.h |   0
 .../{ => uapi}/linux/netfilter/nfnetlink_queue.h   |   0
 include/uapi/linux/netfilter/x_tables.h            | 187 ++++++++++++++
 include/{ => uapi}/linux/netfilter/xt_AUDIT.h      |   0
 include/{ => uapi}/linux/netfilter/xt_CHECKSUM.h   |   0
 include/{ => uapi}/linux/netfilter/xt_CLASSIFY.h   |   0
 include/{ => uapi}/linux/netfilter/xt_CONNMARK.h   |   0
 .../{ => uapi}/linux/netfilter/xt_CONNSECMARK.h    |   0
 include/{ => uapi}/linux/netfilter/xt_CT.h         |   0
 include/{ => uapi}/linux/netfilter/xt_DSCP.h       |   0
 include/{ => uapi}/linux/netfilter/xt_IDLETIMER.h  |   0
 include/{ => uapi}/linux/netfilter/xt_LED.h        |   0
 include/{ => uapi}/linux/netfilter/xt_LOG.h        |   0
 include/{ => uapi}/linux/netfilter/xt_MARK.h       |   0
 include/{ => uapi}/linux/netfilter/xt_NFLOG.h      |   0
 include/{ => uapi}/linux/netfilter/xt_NFQUEUE.h    |   0
 include/{ => uapi}/linux/netfilter/xt_RATEEST.h    |   0
 include/{ => uapi}/linux/netfilter/xt_SECMARK.h    |   0
 include/{ => uapi}/linux/netfilter/xt_TCPMSS.h     |   0
 .../{ => uapi}/linux/netfilter/xt_TCPOPTSTRIP.h    |   0
 include/{ => uapi}/linux/netfilter/xt_TEE.h        |   0
 include/{ => uapi}/linux/netfilter/xt_TPROXY.h     |   0
 include/{ => uapi}/linux/netfilter/xt_addrtype.h   |   0
 include/{ => uapi}/linux/netfilter/xt_cluster.h    |   0
 include/{ => uapi}/linux/netfilter/xt_comment.h    |   0
 include/{ => uapi}/linux/netfilter/xt_connbytes.h  |   0
 include/{ => uapi}/linux/netfilter/xt_connlimit.h  |   0
 include/{ => uapi}/linux/netfilter/xt_connmark.h   |   0
 include/{ => uapi}/linux/netfilter/xt_conntrack.h  |   0
 include/{ => uapi}/linux/netfilter/xt_cpu.h        |   0
 include/{ => uapi}/linux/netfilter/xt_dccp.h       |   0
 include/{ => uapi}/linux/netfilter/xt_devgroup.h   |   0
 include/{ => uapi}/linux/netfilter/xt_dscp.h       |   0
 include/{ => uapi}/linux/netfilter/xt_ecn.h        |   0
 include/{ => uapi}/linux/netfilter/xt_esp.h        |   0
 include/uapi/linux/netfilter/xt_hashlimit.h        |  73 ++++++
 include/{ => uapi}/linux/netfilter/xt_helper.h     |   0
 include/{ => uapi}/linux/netfilter/xt_iprange.h    |   0
 include/{ => uapi}/linux/netfilter/xt_ipvs.h       |   0
 include/{ => uapi}/linux/netfilter/xt_length.h     |   0
 include/{ => uapi}/linux/netfilter/xt_limit.h      |   0
 include/{ => uapi}/linux/netfilter/xt_mac.h        |   0
 include/{ => uapi}/linux/netfilter/xt_mark.h       |   0
 include/{ => uapi}/linux/netfilter/xt_multiport.h  |   0
 include/{ => uapi}/linux/netfilter/xt_nfacct.h     |   0
 include/{ => uapi}/linux/netfilter/xt_osf.h        |   0
 include/{ => uapi}/linux/netfilter/xt_owner.h      |   0
 include/uapi/linux/netfilter/xt_physdev.h          |  23 ++
 include/{ => uapi}/linux/netfilter/xt_pkttype.h    |   0
 include/{ => uapi}/linux/netfilter/xt_policy.h     |   0
 include/{ => uapi}/linux/netfilter/xt_quota.h      |   0
 include/{ => uapi}/linux/netfilter/xt_rateest.h    |   0
 include/{ => uapi}/linux/netfilter/xt_realm.h      |   0
 include/{ => uapi}/linux/netfilter/xt_recent.h     |   0
 include/{ => uapi}/linux/netfilter/xt_sctp.h       |   0
 include/{ => uapi}/linux/netfilter/xt_set.h        |   0
 include/{ => uapi}/linux/netfilter/xt_socket.h     |   0
 include/{ => uapi}/linux/netfilter/xt_state.h      |   0
 include/{ => uapi}/linux/netfilter/xt_statistic.h  |   0
 include/{ => uapi}/linux/netfilter/xt_string.h     |   0
 include/{ => uapi}/linux/netfilter/xt_tcpmss.h     |   0
 include/{ => uapi}/linux/netfilter/xt_tcpudp.h     |   0
 include/{ => uapi}/linux/netfilter/xt_time.h       |   0
 include/{ => uapi}/linux/netfilter/xt_u32.h        |   0
 include/uapi/linux/netfilter_arp/Kbuild            |   2 +
 include/uapi/linux/netfilter_arp/arp_tables.h      | 206 ++++++++++++++++
 .../{ => uapi}/linux/netfilter_arp/arpt_mangle.h   |   0
 include/uapi/linux/netfilter_bridge/Kbuild         |  18 ++
 include/uapi/linux/netfilter_bridge/ebt_802_3.h    |  62 +++++
 .../{ => uapi}/linux/netfilter_bridge/ebt_among.h  |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_arp.h    |   0
 .../linux/netfilter_bridge/ebt_arpreply.h          |   0
 include/{ => uapi}/linux/netfilter_bridge/ebt_ip.h |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_ip6.h    |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_limit.h  |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_log.h    |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_mark_m.h |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_mark_t.h |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_nat.h    |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_nflog.h  |   0
 .../linux/netfilter_bridge/ebt_pkttype.h           |   0
 .../linux/netfilter_bridge/ebt_redirect.h          |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_stp.h    |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_ulog.h   |   0
 .../{ => uapi}/linux/netfilter_bridge/ebt_vlan.h   |   0
 include/uapi/linux/netfilter_bridge/ebtables.h     | 268 +++++++++++++++++++++
 include/uapi/linux/netfilter_ipv4/Kbuild           |  10 +
 include/uapi/linux/netfilter_ipv4/ip_tables.h      | 229 ++++++++++++++++++
 .../linux/netfilter_ipv4/ipt_CLUSTERIP.h           |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ECN.h  |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_LOG.h  |   0
 .../{ => uapi}/linux/netfilter_ipv4/ipt_REJECT.h   |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_TTL.h  |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ULOG.h |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ah.h   |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ecn.h  |   0
 include/{ => uapi}/linux/netfilter_ipv4/ipt_ttl.h  |   0
 include/uapi/linux/netfilter_ipv6/Kbuild           |  12 +
 include/uapi/linux/netfilter_ipv6/ip6_tables.h     | 267 ++++++++++++++++++++
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_HL.h  |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_LOG.h |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_NPT.h |   0
 .../{ => uapi}/linux/netfilter_ipv6/ip6t_REJECT.h  |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_ah.h  |   0
 .../{ => uapi}/linux/netfilter_ipv6/ip6t_frag.h    |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_hl.h  |   0
 .../linux/netfilter_ipv6/ip6t_ipv6header.h         |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_mh.h  |   0
 .../{ => uapi}/linux/netfilter_ipv6/ip6t_opts.h    |   0
 include/{ => uapi}/linux/netfilter_ipv6/ip6t_rt.h  |   0
 include/uapi/linux/tc_act/Kbuild                   |   7 +
 include/{ => uapi}/linux/tc_act/tc_csum.h          |   0
 include/{ => uapi}/linux/tc_act/tc_gact.h          |   0
 include/{ => uapi}/linux/tc_act/tc_ipt.h           |   0
 include/{ => uapi}/linux/tc_act/tc_mirred.h        |   0
 include/{ => uapi}/linux/tc_act/tc_nat.h           |   0
 include/{ => uapi}/linux/tc_act/tc_pedit.h         |   0
 include/{ => uapi}/linux/tc_act/tc_skbedit.h       |   0
 include/uapi/linux/tc_ematch/Kbuild                |   4 +
 include/{ => uapi}/linux/tc_ematch/tc_em_cmp.h     |   0
 include/{ => uapi}/linux/tc_ematch/tc_em_meta.h    |   0
 include/{ => uapi}/linux/tc_ematch/tc_em_nbyte.h   |   0
 include/{ => uapi}/linux/tc_ematch/tc_em_text.h    |   0
 170 files changed, 2026 insertions(+), 1917 deletions(-)
 rename include/{ => uapi}/linux/caif/caif_socket.h (100%)
 rename include/{ => uapi}/linux/caif/if_caif.h (100%)
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set.h
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set_bitmap.h
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set_hash.h
 create mode 100644 include/uapi/linux/netfilter/ipset/ip_set_list.h
 create mode 100644 include/uapi/linux/netfilter/nf_conntrack_common.h
 create mode 100644 include/uapi/linux/netfilter/nf_conntrack_ftp.h
 rename include/{ => uapi}/linux/netfilter/nf_conntrack_sctp.h (100%)
 create mode 100644 include/uapi/linux/netfilter/nf_conntrack_tcp.h
 rename include/{ => uapi}/linux/netfilter/nf_conntrack_tuple_common.h (100%)
 rename include/{ => uapi}/linux/netfilter/nf_nat.h (100%)
 create mode 100644 include/uapi/linux/netfilter/nfnetlink.h
 create mode 100644 include/uapi/linux/netfilter/nfnetlink_acct.h
 rename include/{ => uapi}/linux/netfilter/nfnetlink_compat.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_conntrack.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_cthelper.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_cttimeout.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_log.h (100%)
 rename include/{ => uapi}/linux/netfilter/nfnetlink_queue.h (100%)
 create mode 100644 include/uapi/linux/netfilter/x_tables.h
 rename include/{ => uapi}/linux/netfilter/xt_AUDIT.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CHECKSUM.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CLASSIFY.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CONNMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CONNSECMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_CT.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_DSCP.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_IDLETIMER.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_LED.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_LOG.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_MARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_NFLOG.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_NFQUEUE.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_RATEEST.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_SECMARK.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TCPMSS.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TCPOPTSTRIP.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TEE.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_TPROXY.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_addrtype.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_cluster.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_comment.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_connbytes.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_connlimit.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_connmark.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_conntrack.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_cpu.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_dccp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_devgroup.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_dscp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_ecn.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_esp.h (100%)
 create mode 100644 include/uapi/linux/netfilter/xt_hashlimit.h
 rename include/{ => uapi}/linux/netfilter/xt_helper.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_iprange.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_ipvs.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_length.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_limit.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_mac.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_mark.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_multiport.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_nfacct.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_osf.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_owner.h (100%)
 create mode 100644 include/uapi/linux/netfilter/xt_physdev.h
 rename include/{ => uapi}/linux/netfilter/xt_pkttype.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_policy.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_quota.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_rateest.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_realm.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_recent.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_sctp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_set.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_socket.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_state.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_statistic.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_string.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_tcpmss.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_tcpudp.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_time.h (100%)
 rename include/{ => uapi}/linux/netfilter/xt_u32.h (100%)
 create mode 100644 include/uapi/linux/netfilter_arp/arp_tables.h
 rename include/{ => uapi}/linux/netfilter_arp/arpt_mangle.h (100%)
 create mode 100644 include/uapi/linux/netfilter_bridge/ebt_802_3.h
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_among.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_arp.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_arpreply.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_ip.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_ip6.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_limit.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_log.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_mark_m.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_mark_t.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_nat.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_nflog.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_pkttype.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_redirect.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_stp.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_ulog.h (100%)
 rename include/{ => uapi}/linux/netfilter_bridge/ebt_vlan.h (100%)
 create mode 100644 include/uapi/linux/netfilter_bridge/ebtables.h
 create mode 100644 include/uapi/linux/netfilter_ipv4/ip_tables.h
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_CLUSTERIP.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ECN.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_LOG.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_REJECT.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_TTL.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ULOG.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ah.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ecn.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv4/ipt_ttl.h (100%)
 create mode 100644 include/uapi/linux/netfilter_ipv6/ip6_tables.h
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_HL.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_LOG.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_NPT.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_REJECT.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_ah.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_frag.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_hl.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_ipv6header.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_mh.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_opts.h (100%)
 rename include/{ => uapi}/linux/netfilter_ipv6/ip6t_rt.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_csum.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_gact.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_ipt.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_mirred.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_nat.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_pedit.h (100%)
 rename include/{ => uapi}/linux/tc_act/tc_skbedit.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_cmp.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_meta.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_nbyte.h (100%)
 rename include/{ => uapi}/linux/tc_ematch/tc_em_text.h (100%)
.
