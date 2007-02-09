From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [NET]: Fix whitespace errors
Date: Fri, 09 Feb 2007 23:41:54 +0900 (JST)
Message-ID: <20070209.234154.22788645.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54395 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946490AbXBIOl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 09:41:57 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Please pull "2.6.20-net-2.6-20070209-whitespace" branch
at <git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
to fix trivial whitespace errors:
 - convert leading sequences of whitespace with tab(s).
 - remove whitespace at the end of line.
under net.

Tree is on top of current net-2.6 tree.

Here is the diffstat.

---
 net/802/fc.c                                       |   24 -
 net/802/fddi.c                                     |   26 +
 net/802/hippi.c                                    |   20 -
 net/802/psnap.c                                    |    2 
 net/802/tr.c                                       |  136 +++--
 net/8021q/vlan.c                                   |   52 +-
 net/8021q/vlan.h                                   |   12 
 net/8021q/vlan_dev.c                               |   42 +-
 net/8021q/vlanproc.c                               |   36 +
 net/appletalk/aarp.c                               |   14 -
 net/appletalk/atalk_proc.c                         |    2 
 net/appletalk/ddp.c                                |  218 ++++----
 net/appletalk/dev.c                                |    8 
 net/atm/atm_sysfs.c                                |   14 -
 net/atm/br2684.c                                   |    4 
 net/atm/common.c                                   |   34 +
 net/atm/common.h                                   |    2 
 net/atm/ioctl.c                                    |    2 
 net/atm/lec.c                                      |   20 -
 net/atm/lec.h                                      |    4 
 net/atm/mpc.c                                      |  130 +++--
 net/atm/mpc.h                                      |   44 +-
 net/atm/mpoa_caches.c                              |    4 
 net/atm/mpoa_caches.h                              |   98 ++--
 net/atm/mpoa_proc.c                                |   88 ++-
 net/atm/proc.c                                     |   58 +-
 net/atm/pvc.c                                      |    4 
 net/atm/raw.c                                      |    6 
 net/atm/resources.c                                |   16 -
 net/atm/signaling.h                                |    4 
 net/atm/svc.c                                      |   48 +-
 net/ax25/af_ax25.c                                 |  114 ++--
 net/ax25/ax25_addr.c                               |    6 
 net/ax25/ax25_ip.c                                 |   94 ++--
 net/ax25/ax25_route.c                              |    8 
 net/ax25/ax25_std_timer.c                          |    2 
 net/ax25/ax25_subr.c                               |    4 
 net/ax25/ax25_uid.c                                |    2 
 net/bluetooth/af_bluetooth.c                       |   16 -
 net/bluetooth/bnep/bnep.h                          |   18 -
 net/bluetooth/bnep/core.c                          |   52 +-
 net/bluetooth/bnep/netdev.c                        |   34 +
 net/bluetooth/bnep/sock.c                          |   26 +
 net/bluetooth/cmtp/capi.c                          |   14 -
 net/bluetooth/cmtp/cmtp.h                          |   12 
 net/bluetooth/cmtp/core.c                          |   14 -
 net/bluetooth/cmtp/sock.c                          |   14 -
 net/bluetooth/hci_conn.c                           |   20 -
 net/bluetooth/hci_core.c                           |   36 +
 net/bluetooth/hci_event.c                          |   26 +
 net/bluetooth/hci_sock.c                           |   28 +
 net/bluetooth/hidp/core.c                          |   14 -
 net/bluetooth/hidp/hidp.h                          |   12 
 net/bluetooth/hidp/sock.c                          |   14 -
 net/bluetooth/l2cap.c                              |   26 +
 net/bluetooth/lib.c                                |   12 
 net/bluetooth/rfcomm/core.c                        |   56 +-
 net/bluetooth/rfcomm/sock.c                        |   20 -
 net/bluetooth/rfcomm/tty.c                         |   46 +-
 net/bluetooth/sco.c                                |   30 +
 net/bridge/br_device.c                             |    8 
 net/bridge/br_fdb.c                                |   34 +
 net/bridge/br_forward.c                            |    4 
 net/bridge/br_if.c                                 |   26 +
 net/bridge/br_input.c                              |    4 
 net/bridge/br_ioctl.c                              |   18 -
 net/bridge/br_netfilter.c                          |   14 -
 net/bridge/br_notify.c                             |   10 
 net/bridge/br_private.h                            |    4 
 net/bridge/br_stp.c                                |   24 -
 net/bridge/br_stp_bpdu.c                           |    2 
 net/bridge/br_stp_if.c                             |    4 
 net/bridge/br_stp_timer.c                          |   20 -
 net/bridge/br_sysfs_br.c                           |    8 
 net/bridge/netfilter/ebt_802_3.c                   |    6 
 net/bridge/netfilter/ebt_among.c                   |    6 
 net/bridge/netfilter/ebt_arpreply.c                |    2 
 net/bridge/netfilter/ebt_ip.c                      |    8 
 net/bridge/netfilter/ebt_log.c                     |    6 
 net/bridge/netfilter/ebt_mark_m.c                  |    2 
 net/bridge/netfilter/ebt_stp.c                     |    4 
 net/bridge/netfilter/ebt_ulog.c                    |   16 -
 net/bridge/netfilter/ebt_vlan.c                    |    6 
 net/bridge/netfilter/ebtable_filter.c              |    4 
 net/bridge/netfilter/ebtables.c                    |   16 -
 net/compat.c                                       |   16 -
 net/core/datagram.c                                |    2 
 net/core/dev.c                                     |   96 ++--
 net/core/dev_mcast.c                               |   28 +
 net/core/dst.c                                     |    6 
 net/core/ethtool.c                                 |   10 
 net/core/filter.c                                  |    8 
 net/core/gen_estimator.c                           |    6 
 net/core/gen_stats.c                               |    2 
 net/core/iovec.c                                   |   10 
 net/core/link_watch.c                              |    4 
 net/core/neighbour.c                               |   50 +-
 net/core/net-sysfs.c                               |   10 
 net/core/netpoll.c                                 |   18 -
 net/core/pktgen.c                                  |   62 +-
 net/core/rtnetlink.c                               |    2 
 net/core/scm.c                                     |   12 
 net/core/skbuff.c                                  |   14 -
 net/core/sock.c                                    |  148 +++---
 net/core/stream.c                                  |    4 
 net/core/user_dma.c                                |    8 
 net/core/utils.c                                   |    4 
 net/core/wireless.c                                |   20 -
 net/dccp/ccids/ccid2.c                             |   68 +--
 net/dccp/ccids/ccid3.c                             |   14 -
 net/dccp/ccids/lib/packet_history.h                |    4 
 net/dccp/ccids/lib/tfrc_equation.c                 |   18 -
 net/dccp/dccp.h                                    |    8 
 net/dccp/feat.c                                    |    8 
 net/dccp/feat.h                                    |    2 
 net/dccp/input.c                                   |   14 -
 net/dccp/ipv4.c                                    |    6 
 net/dccp/ipv6.c                                    |    2 
 net/dccp/options.c                                 |    4 
 net/dccp/output.c                                  |    4 
 net/dccp/proto.c                                   |    2 
 net/dccp/timer.c                                   |    2 
 net/decnet/af_decnet.c                             |  130 +++--
 net/decnet/dn_dev.c                                |  102 ++--
 net/decnet/dn_fib.c                                |  132 +++--
 net/decnet/dn_neigh.c                              |   24 -
 net/decnet/dn_nsp_in.c                             |   74 +--
 net/decnet/dn_nsp_out.c                            |   56 +-
 net/decnet/dn_route.c                              |  172 +++----
 net/decnet/dn_table.c                              |  238 +++++----
 net/decnet/netfilter/dn_rtmsg.c                    |    2 
 net/decnet/sysctl_net_decnet.c                     |   84 ++-
 net/econet/af_econet.c                             |   64 +-
 net/ethernet/eth.c                                 |    8 
 net/ieee80211/ieee80211_crypt_wep.c                |    8 
 net/ieee80211/ieee80211_rx.c                       |    6 
 net/ieee80211/ieee80211_tx.c                       |    6 
 net/ieee80211/ieee80211_wx.c                       |    4 
 net/ieee80211/softmac/ieee80211softmac_assoc.c     |   20 -
 net/ieee80211/softmac/ieee80211softmac_auth.c      |   78 ++-
 net/ieee80211/softmac/ieee80211softmac_event.c     |   12 
 net/ieee80211/softmac/ieee80211softmac_io.c        |   64 +-
 net/ieee80211/softmac/ieee80211softmac_module.c    |   48 +-
 net/ieee80211/softmac/ieee80211softmac_priv.h      |   12 
 net/ieee80211/softmac/ieee80211softmac_scan.c      |   14 -
 net/ieee80211/softmac/ieee80211softmac_wx.c        |   18 -
 net/ipv4/af_inet.c                                 |   72 +--
 net/ipv4/ah4.c                                     |   20 -
 net/ipv4/arp.c                                     |   66 +--
 net/ipv4/datagram.c                                |   14 -
 net/ipv4/devinet.c                                 |   46 +-
 net/ipv4/esp4.c                                    |    8 
 net/ipv4/fib_frontend.c                            |   22 -
 net/ipv4/fib_hash.c                                |   10 
 net/ipv4/fib_semantics.c                           |   14 -
 net/ipv4/fib_trie.c                                |   98 ++--
 net/ipv4/icmp.c                                    |   16 -
 net/ipv4/igmp.c                                    |   46 +-
 net/ipv4/inet_connection_sock.c                    |    6 
 net/ipv4/inet_diag.c                               |    4 
 net/ipv4/inet_hashtables.c                         |  104 ++--
 net/ipv4/ip_forward.c                              |   22 -
 net/ipv4/ip_fragment.c                             |   18 -
 net/ipv4/ip_gre.c                                  |   16 -
 net/ipv4/ip_input.c                                |   28 +
 net/ipv4/ip_options.c                              |   14 -
 net/ipv4/ip_output.c                               |   42 +-
 net/ipv4/ip_sockglue.c                             |   82 ++-
 net/ipv4/ipcomp.c                                  |   32 +
 net/ipv4/ipconfig.c                                |   30 +
 net/ipv4/ipip.c                                    |   14 -
 net/ipv4/ipmr.c                                    |  126 ++---
 net/ipv4/ipvs/ip_vs_conn.c                         |   10 
 net/ipv4/ipvs/ip_vs_core.c                         |   20 -
 net/ipv4/ipvs/ip_vs_ftp.c                          |    2 
 net/ipv4/ipvs/ip_vs_lblc.c                         |   12 
 net/ipv4/ipvs/ip_vs_lblcr.c                        |    8 
 net/ipv4/ipvs/ip_vs_rr.c                           |    2 
 net/ipv4/multipath_drr.c                           |    4 
 net/ipv4/multipath_rr.c                            |    2 
 net/ipv4/multipath_wrandom.c                       |    4 
 net/ipv4/netfilter.c                               |    6 
 net/ipv4/netfilter/arp_tables.c                    |    6 
 net/ipv4/netfilter/arpt_mangle.c                   |    2 
 net/ipv4/netfilter/ip_conntrack_amanda.c           |    4 
 net/ipv4/netfilter/ip_conntrack_core.c             |   76 +--
 net/ipv4/netfilter/ip_conntrack_ftp.c              |   12 
 net/ipv4/netfilter/ip_conntrack_helper_h323.c      |    2 
 net/ipv4/netfilter/ip_conntrack_helper_pptp.c      |    6 
 net/ipv4/netfilter/ip_conntrack_irc.c              |   18 -
 net/ipv4/netfilter/ip_conntrack_netbios_ns.c       |    2 
 net/ipv4/netfilter/ip_conntrack_netlink.c          |  118 ++---
 net/ipv4/netfilter/ip_conntrack_proto_icmp.c       |   12 
 net/ipv4/netfilter/ip_conntrack_proto_sctp.c       |   94 ++--
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c        |  276 +++++------
 net/ipv4/netfilter/ip_conntrack_proto_udp.c        |    8 
 net/ipv4/netfilter/ip_conntrack_sip.c              |   10 
 net/ipv4/netfilter/ip_conntrack_standalone.c       |   34 +
 net/ipv4/netfilter/ip_conntrack_tftp.c             |    4 
 net/ipv4/netfilter/ip_nat_core.c                   |   22 -
 net/ipv4/netfilter/ip_nat_ftp.c                    |    6 
 net/ipv4/netfilter/ip_nat_helper.c                 |   34 +
 net/ipv4/netfilter/ip_nat_helper_pptp.c            |   10 
 net/ipv4/netfilter/ip_nat_irc.c                    |    4 
 net/ipv4/netfilter/ip_nat_proto_icmp.c             |    2 
 net/ipv4/netfilter/ip_nat_rule.c                   |    6 
 net/ipv4/netfilter/ip_nat_sip.c                    |   14 -
 net/ipv4/netfilter/ip_nat_snmp_basic.c             |  362 +++++++-------
 net/ipv4/netfilter/ip_nat_standalone.c             |   22 -
 net/ipv4/netfilter/ip_queue.c                      |  150 +++---
 net/ipv4/netfilter/ip_tables.c                     |   10 
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   42 +-
 net/ipv4/netfilter/ipt_ECN.c                       |   10 
 net/ipv4/netfilter/ipt_LOG.c                       |   10 
 net/ipv4/netfilter/ipt_MASQUERADE.c                |    4 
 net/ipv4/netfilter/ipt_NETMAP.c                    |    4 
 net/ipv4/netfilter/ipt_REDIRECT.c                  |    2 
 net/ipv4/netfilter/ipt_REJECT.c                    |   48 +-
 net/ipv4/netfilter/ipt_SAME.c                      |   16 -
 net/ipv4/netfilter/ipt_TOS.c                       |    4 
 net/ipv4/netfilter/ipt_TTL.c                       |    8 
 net/ipv4/netfilter/ipt_ULOG.c                      |   30 +
 net/ipv4/netfilter/ipt_addrtype.c                  |    2 
 net/ipv4/netfilter/ipt_ah.c                        |    4 
 net/ipv4/netfilter/ipt_iprange.c                   |    4 
 net/ipv4/netfilter/ipt_owner.c                     |    6 
 net/ipv4/netfilter/ipt_ttl.c                       |    4 
 net/ipv4/netfilter/iptable_filter.c                |    2 
 net/ipv4/netfilter/iptable_mangle.c                |    6 
 net/ipv4/netfilter/iptable_raw.c                   |   26 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   24 -
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    8 
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |   30 +
 net/ipv4/netfilter/nf_nat_core.c                   |   16 -
 net/ipv4/netfilter/nf_nat_h323.c                   |    2 
 net/ipv4/netfilter/nf_nat_helper.c                 |   10 
 net/ipv4/netfilter/nf_nat_pptp.c                   |   10 
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |    2 
 net/ipv4/netfilter/nf_nat_rule.c                   |   18 -
 net/ipv4/netfilter/nf_nat_sip.c                    |   14 -
 net/ipv4/netfilter/nf_nat_snmp_basic.c             |   98 ++--
 net/ipv4/netfilter/nf_nat_standalone.c             |   20 -
 net/ipv4/proc.c                                    |   10 
 net/ipv4/protocol.c                                |    2 
 net/ipv4/raw.c                                     |   26 +
 net/ipv4/route.c                                   |  110 ++--
 net/ipv4/syncookies.c                              |   58 +-
 net/ipv4/sysctl_net_ipv4.c                         |   20 -
 net/ipv4/tcp.c                                     |   12 
 net/ipv4/tcp_cong.c                                |   38 +
 net/ipv4/tcp_cubic.c                               |   50 +-
 net/ipv4/tcp_highspeed.c                           |    4 
 net/ipv4/tcp_htcp.c                                |    2 
 net/ipv4/tcp_input.c                               |  116 ++---
 net/ipv4/tcp_ipv4.c                                |   20 -
 net/ipv4/tcp_minisocks.c                           |   12 
 net/ipv4/tcp_output.c                              |   62 +-
 net/ipv4/tcp_timer.c                               |   12 
 net/ipv4/tcp_vegas.c                               |    4 
 net/ipv4/tcp_westwood.c                            |   24 -
 net/ipv4/udp.c                                     |  100 ++--
 net/ipv4/udp_impl.h                                |    2 
 net/ipv4/xfrm4_input.c                             |    6 
 net/ipv4/xfrm4_output.c                            |    8 
 net/ipv4/xfrm4_policy.c                            |    8 
 net/ipv4/xfrm4_tunnel.c                            |    2 
 net/ipv6/addrconf.c                                |  198 ++++----
 net/ipv6/af_inet6.c                                |   40 +-
 net/ipv6/ah6.c                                     |   40 +-
 net/ipv6/anycast.c                                 |    4 
 net/ipv6/datagram.c                                |   52 +-
 net/ipv6/esp6.c                                    |   30 +
 net/ipv6/exthdrs.c                                 |   14 -
 net/ipv6/exthdrs_core.c                            |   16 -
 net/ipv6/icmp.c                                    |   38 +
 net/ipv6/inet6_hashtables.c                        |   98 ++--
 net/ipv6/ip6_fib.c                                 |   46 +-
 net/ipv6/ip6_flowlabel.c                           |    4 
 net/ipv6/ip6_input.c                               |   18 -
 net/ipv6/ip6_output.c                              |   24 -
 net/ipv6/ip6_tunnel.c                              |   84 ++-
 net/ipv6/ipcomp6.c                                 |   22 -
 net/ipv6/ipv6_sockglue.c                           |   12 
 net/ipv6/mcast.c                                   |   36 +
 net/ipv6/mip6.c                                    |    2 
 net/ipv6/ndisc.c                                   |  138 +++--
 net/ipv6/netfilter.c                               |    4 
 net/ipv6/netfilter/ip6_queue.c                     |  152 +++---
 net/ipv6/netfilter/ip6_tables.c                    |   40 +-
 net/ipv6/netfilter/ip6t_HL.c                       |   12 
 net/ipv6/netfilter/ip6t_LOG.c                      |   10 
 net/ipv6/netfilter/ip6t_REJECT.c                   |   36 +
 net/ipv6/netfilter/ip6t_ah.c                       |   22 -
 net/ipv6/netfilter/ip6t_hl.c                       |    2 
 net/ipv6/netfilter/ip6t_ipv6header.c               |    2 
 net/ipv6/netfilter/ip6table_mangle.c               |   10 
 net/ipv6/netfilter/ip6table_raw.c                  |   16 -
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |    4 
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |    6 
 net/ipv6/netfilter/nf_conntrack_reasm.c            |   50 +-
 net/ipv6/proc.c                                    |   22 -
 net/ipv6/protocol.c                                |    2 
 net/ipv6/raw.c                                     |   78 ++-
 net/ipv6/reassembly.c                              |   32 +
 net/ipv6/route.c                                   |   88 ++-
 net/ipv6/sit.c                                     |   10 
 net/ipv6/sysctl_net_ipv6.c                         |    4 
 net/ipv6/tcp_ipv6.c                                |   98 ++--
 net/ipv6/udp.c                                     |   60 +-
 net/ipv6/udp_impl.h                                |    6 
 net/ipv6/xfrm6_input.c                             |   18 -
 net/ipv6/xfrm6_output.c                            |    8 
 net/ipv6/xfrm6_policy.c                            |    6 
 net/ipv6/xfrm6_state.c                             |    2 
 net/ipv6/xfrm6_tunnel.c                            |   22 -
 net/ipx/af_ipx.c                                   |   84 ++-
 net/ipx/ipx_proc.c                                 |    2 
 net/ipx/ipx_route.c                                |    4 
 net/ipx/sysctl_net_ipx.c                           |    2 
 net/irda/af_irda.c                                 |   12 
 net/irda/discovery.c                               |   58 +-
 net/irda/ircomm/ircomm_core.c                      |   98 ++--
 net/irda/ircomm/ircomm_event.c                     |   72 +--
 net/irda/ircomm/ircomm_lmp.c                       |  110 ++--
 net/irda/ircomm/ircomm_param.c                     |   94 ++--
 net/irda/ircomm/ircomm_ttp.c                       |   88 ++-
 net/irda/ircomm/ircomm_tty.c                       |  288 ++++++-----
 net/irda/ircomm/ircomm_tty_attach.c                |  236 +++++----
 net/irda/ircomm/ircomm_tty_ioctl.c                 |   86 ++-
 net/irda/irda_device.c                             |   22 -
 net/irda/iriap.c                                   |   20 -
 net/irda/irias_object.c                            |    6 
 net/irda/irlan/irlan_client.c                      |  150 +++---
 net/irda/irlan/irlan_client_event.c                |  190 ++++---
 net/irda/irlan/irlan_common.c                      |  318 ++++++------
 net/irda/irlan/irlan_eth.c                         |  102 ++--
 net/irda/irlan/irlan_event.c                       |   26 +
 net/irda/irlan/irlan_filter.c                      |   48 +-
 net/irda/irlan/irlan_provider.c                    |  102 ++--
 net/irda/irlan/irlan_provider_event.c              |   68 +--
 net/irda/irlap.c                                   |   14 -
 net/irda/irlap_event.c                             |    6 
 net/irda/irlap_frame.c                             |    6 
 net/irda/irlmp.c                                   |   16 -
 net/irda/irlmp_event.c                             |    2 
 net/irda/irlmp_frame.c                             |  122 ++---
 net/irda/irmod.c                                   |   42 +-
 net/irda/irnet/irnet.h                             |    4 
 net/irda/irnet/irnet_irda.c                        |   38 +
 net/irda/irnet/irnet_irda.h                        |    2 
 net/irda/irnet/irnet_ppp.c                         |   10 
 net/irda/irproc.c                                  |   40 +-
 net/irda/irqueue.c                                 |  106 ++--
 net/irda/irsysctl.c                                |   24 -
 net/irda/irttp.c                                   |   40 +-
 net/irda/parameters.c                              |    2 
 net/irda/qos.c                                     |  150 +++---
 net/irda/timer.c                                   |   62 +-
 net/irda/wrapper.c                                 |    2 
 net/key/af_key.c                                   |  156 +++---
 net/lapb/lapb_iface.c                              |    6 
 net/lapb/lapb_out.c                                |    4 
 net/lapb/lapb_subr.c                               |   16 -
 net/lapb/lapb_timer.c                              |    2 
 net/llc/af_llc.c                                   |   18 -
 net/llc/llc_conn.c                                 |    2 
 net/llc/llc_input.c                                |    8 
 net/llc/llc_output.c                               |    2 
 net/llc/llc_pdu.c                                  |    2 
 net/llc/llc_proc.c                                 |   16 -
 net/llc/llc_s_st.c                                 |    2 
 net/llc/llc_sap.c                                  |    6 
 net/llc/llc_station.c                              |   22 -
 net/llc/sysctl_net_llc.c                           |    8 
 net/netfilter/core.c                               |    6 
 net/netfilter/nf_conntrack_core.c                  |   18 -
 net/netfilter/nf_conntrack_expect.c                |    2 
 net/netfilter/nf_conntrack_ftp.c                   |   14 -
 net/netfilter/nf_conntrack_h323_main.c             |   20 -
 net/netfilter/nf_conntrack_irc.c                   |    2 
 net/netfilter/nf_conntrack_l3proto_generic.c       |    2 
 net/netfilter/nf_conntrack_netbios_ns.c            |    2 
 net/netfilter/nf_conntrack_netlink.c               |  106 ++--
 net/netfilter/nf_conntrack_pptp.c                  |    2 
 net/netfilter/nf_conntrack_proto_sctp.c            |   72 +--
 net/netfilter/nf_conntrack_proto_tcp.c             |  204 ++++----
 net/netfilter/nf_conntrack_sip.c                   |    6 
 net/netfilter/nf_conntrack_standalone.c            |    4 
 net/netfilter/nf_conntrack_tftp.c                  |    2 
 net/netfilter/nf_internals.h                       |    2 
 net/netfilter/nf_log.c                             |    8 
 net/netfilter/nf_queue.c                           |   22 -
 net/netfilter/nf_sockopt.c                         |   12 
 net/netfilter/nfnetlink.c                          |   10 
 net/netfilter/nfnetlink_log.c                      |   52 +-
 net/netfilter/nfnetlink_queue.c                    |   84 ++-
 net/netfilter/x_tables.c                           |   12 
 net/netfilter/xt_CLASSIFY.c                        |    4 
 net/netfilter/xt_MARK.c                            |    4 
 net/netfilter/xt_NFQUEUE.c                         |    4 
 net/netfilter/xt_NOTRACK.c                         |    4 
 net/netfilter/xt_SECMARK.c                         |    2 
 net/netfilter/xt_conntrack.c                       |   32 +
 net/netfilter/xt_dccp.c                            |   20 -
 net/netfilter/xt_hashlimit.c                       |    8 
 net/netfilter/xt_helper.c                          |   18 -
 net/netfilter/xt_length.c                          |    4 
 net/netfilter/xt_limit.c                           |    2 
 net/netfilter/xt_mark.c                            |    6 
 net/netfilter/xt_multiport.c                       |    2 
 net/netfilter/xt_physdev.c                         |    2 
 net/netfilter/xt_policy.c                          |   24 -
 net/netfilter/xt_quota.c                           |    4 
 net/netfilter/xt_realm.c                           |    2 
 net/netfilter/xt_sctp.c                            |   30 +
 net/netfilter/xt_string.c                          |    8 
 net/netfilter/xt_tcpmss.c                          |    4 
 net/netlabel/netlabel_cipso_v4.c                   |    8 
 net/netlink/af_netlink.c                           |   44 +-
 net/netlink/genetlink.c                            |    2 
 net/netrom/af_netrom.c                             |   38 +
 net/netrom/nr_route.c                              |   18 -
 net/netrom/nr_subr.c                               |    2 
 net/netrom/nr_timer.c                              |    2 
 net/netrom/sysctl_net_netrom.c                     |   26 +
 net/packet/af_packet.c                             |   78 ++-
 net/rose/af_rose.c                                 |   12 
 net/rose/rose_route.c                              |   36 +
 net/rose/sysctl_net_rose.c                         |   20 -
 net/rxrpc/connection.c                             |   10 
 net/rxrpc/internal.h                               |    2 
 net/rxrpc/krxiod.c                                 |    2 
 net/rxrpc/krxsecd.c                                |    2 
 net/rxrpc/main.c                                   |   44 +-
 net/rxrpc/sysctl.c                                 |   12 
 net/rxrpc/transport.c                              |    6 
 net/sched/act_api.c                                |   34 +
 net/sched/act_gact.c                               |    2 
 net/sched/act_ipt.c                                |    4 
 net/sched/act_pedit.c                              |   10 
 net/sched/act_police.c                             |   12 
 net/sched/act_simple.c                             |    6 
 net/sched/cls_api.c                                |   14 -
 net/sched/cls_basic.c                              |    6 
 net/sched/cls_fw.c                                 |    4 
 net/sched/cls_rsvp.h                               |    8 
 net/sched/cls_tcindex.c                            |   12 
 net/sched/cls_u32.c                                |    4 
 net/sched/em_cmp.c                                 |    2 
 net/sched/em_meta.c                                |   12 
 net/sched/em_nbyte.c                               |    4 
 net/sched/em_text.c                                |    4 
 net/sched/em_u32.c                                 |    6 
 net/sched/ematch.c                                 |   12 
 net/sched/sch_api.c                                |   18 -
 net/sched/sch_atm.c                                |   22 -
 net/sched/sch_cbq.c                                |   32 +
 net/sched/sch_dsmark.c                             |   16 -
 net/sched/sch_generic.c                            |   28 +
 net/sched/sch_gred.c                               |    4 
 net/sched/sch_hfsc.c                               |   26 +
 net/sched/sch_htb.c                                |   28 +
 net/sched/sch_ingress.c                            |   30 +
 net/sched/sch_netem.c                              |   26 +
 net/sched/sch_prio.c                               |    6 
 net/sched/sch_red.c                                |    2 
 net/sched/sch_sfq.c                                |    6 
 net/sched/sch_tbf.c                                |    6 
 net/sched/sch_teql.c                               |    8 
 net/sctp/associola.c                               |   10 
 net/sctp/bind_addr.c                               |   12 
 net/sctp/crc32c.c                                  |   38 +
 net/sctp/debug.c                                   |   32 +
 net/sctp/endpointola.c                             |    2 
 net/sctp/input.c                                   |   16 -
 net/sctp/inqueue.c                                 |   34 +
 net/sctp/ipv6.c                                    |    2 
 net/sctp/objcnt.c                                  |   34 +
 net/sctp/output.c                                  |   12 
 net/sctp/outqueue.c                                |   30 +
 net/sctp/primitive.c                               |    4 
 net/sctp/proc.c                                    |    4 
 net/sctp/protocol.c                                |   24 -
 net/sctp/sm_make_chunk.c                           |   88 ++-
 net/sctp/sm_sideeffect.c                           |   68 +--
 net/sctp/sm_statefuns.c                            |  110 ++--
 net/sctp/sm_statetable.c                           |    2 
 net/sctp/socket.c                                  |  114 ++--
 net/sctp/transport.c                               |   14 -
 net/sctp/tsnmap.c                                  |    2 
 net/sctp/ulpevent.c                                |   22 -
 net/sctp/ulpqueue.c                                |   60 +-
 net/socket.c                                       |    2 
 net/sunrpc/auth.c                                  |    2 
 net/sunrpc/auth_gss/auth_gss.c                     |   20 -
 net/sunrpc/auth_gss/gss_generic_token.c            |   10 
 net/sunrpc/auth_gss/gss_krb5_crypto.c              |    4 
 net/sunrpc/auth_gss/gss_krb5_seqnum.c              |    4 
 net/sunrpc/auth_gss/gss_mech_switch.c              |    4 
 net/sunrpc/auth_gss/gss_spkm3_token.c              |   48 +-
 net/sunrpc/auth_gss/gss_spkm3_unseal.c             |    2 
 net/sunrpc/auth_gss/svcauth_gss.c                  |    6 
 net/sunrpc/cache.c                                 |   64 +-
 net/sunrpc/clnt.c                                  |   28 +
 net/sunrpc/pmap_clnt.c                             |    4 
 net/sunrpc/sched.c                                 |    8 
 net/sunrpc/svc.c                                   |   24 -
 net/sunrpc/svcauth.c                               |    4 
 net/sunrpc/svcauth_unix.c                          |   12 
 net/sunrpc/svcsock.c                               |   36 +
 net/sunrpc/sysctl.c                                |   10 
 net/sunrpc/xdr.c                                   |    6 
 net/sunrpc/xprt.c                                  |    4 
 net/tipc/addr.c                                    |   14 -
 net/tipc/addr.h                                    |    6 
 net/tipc/bcast.c                                   |   98 ++--
 net/tipc/bcast.h                                   |    6 
 net/tipc/bearer.c                                  |   58 +-
 net/tipc/bearer.h                                  |   22 -
 net/tipc/cluster.c                                 |   22 -
 net/tipc/cluster.h                                 |    4 
 net/tipc/config.c                                  |   16 -
 net/tipc/config.h                                  |    8 
 net/tipc/core.c                                    |   18 -
 net/tipc/core.h                                    |   40 +-
 net/tipc/dbg.c                                     |   56 +-
 net/tipc/dbg.h                                     |    2 
 net/tipc/discover.c                                |   50 +-
 net/tipc/discover.h                                |    2 
 net/tipc/eth_media.c                               |   58 +-
 net/tipc/handler.c                                 |    6 
 net/tipc/link.c                                    |  394 ++++++++-------
 net/tipc/link.h                                    |   32 +
 net/tipc/msg.c                                     |    2 
 net/tipc/msg.h                                     |  138 +++--
 net/tipc/name_distr.c                              |   64 +-
 net/tipc/name_distr.h                              |    2 
 net/tipc/name_table.c                              |  106 ++--
 net/tipc/name_table.h                              |   10 
 net/tipc/net.c                                     |   74 +--
 net/tipc/net.h                                     |    4 
 net/tipc/netlink.c                                 |   16 -
 net/tipc/node.c                                    |  220 ++++-----
 net/tipc/node.h                                    |    8 
 net/tipc/node_subscr.c                             |    6 
 net/tipc/node_subscr.h                             |    2 
 net/tipc/port.c                                    |  226 ++++-----
 net/tipc/port.h                                    |   28 +
 net/tipc/ref.c                                     |   24 -
 net/tipc/ref.h                                     |    8 
 net/tipc/socket.c                                  |  426 ++++++++---------
 net/tipc/subscr.c                                  |   82 ++-
 net/tipc/subscr.h                                  |   16 -
 net/tipc/user_reg.c                                |   22 -
 net/tipc/user_reg.h                                |    2 
 net/tipc/zone.c                                    |    4 
 net/tipc/zone.h                                    |    4 
 net/unix/af_unix.c                                 |   46 +-
 net/unix/garbage.c                                 |   14 -
 net/wanrouter/af_wanpipe.c                         |  514 ++++++++++----------
 net/wanrouter/wanmain.c                            |   18 -
 net/wanrouter/wanproc.c                            |    4 
 net/x25/af_x25.c                                   |   64 +-
 net/x25/sysctl_net_x25.c                           |   10 
 net/x25/x25_dev.c                                  |    6 
 net/x25/x25_facilities.c                           |   10 
 net/x25/x25_in.c                                   |    8 
 net/x25/x25_link.c                                 |    6 
 net/x25/x25_out.c                                  |   10 
 net/x25/x25_proc.c                                 |    8 
 net/x25/x25_route.c                                |    2 
 net/x25/x25_timer.c                                |    6 
 net/xfrm/xfrm_algo.c                               |   94 ++--
 net/xfrm/xfrm_input.c                              |    2 
 net/xfrm/xfrm_policy.c                             |   40 +-
 net/xfrm/xfrm_state.c                              |   18 -
 net/xfrm/xfrm_user.c                               |    6 
 577 files changed, 9382 insertions(+), 9382 deletions(-)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
