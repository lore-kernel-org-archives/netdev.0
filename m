From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: dead CONFIG_ variables:  net/
Date: Thu, 3 May 2007 07:41:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0705030738030.1173@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:51515 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030413AbXECLlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 07:41:35 -0400
Received: from [192.168.1.100] (CPE000c419b52cd-CM001225dbafb6.cpe.net.cable.rogers.com [72.143.66.196])
	(authenticated bits=0)
	by rubicon.netdirect.ca (8.13.1/8.13.1) with ESMTP id l43Bf7YA011899
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 07:41:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  based on a request from patrick mchardy, i'm posting the list of
(ostensibly) "dead" CONFIG_ variables found under the entire net/
directory.  admittedly, there are false positives in this list for a
variety of reasons so don't take everything too seriously, but give it
a perusal to identify actual mistakes or typoes.  (i'll post the same
output for the drivers/net/ output shortly.)



========== BR2684_FAST_TRANS ==========
net/atm/br2684.c:463:#ifdef CONFIG_BR2684_FAST_TRANS
net/atm/br2684.c:467:#endif /* CONFIG_BR2684_FAST_TRANS */
========== BT_BNEP_DEBUG ==========
net/bluetooth/bnep/netdev.c:48:#ifndef CONFIG_BT_BNEP_DEBUG
net/bluetooth/bnep/sock.c:53:#ifndef CONFIG_BT_BNEP_DEBUG
net/bluetooth/bnep/core.c:59:#ifndef CONFIG_BT_BNEP_DEBUG
========== BT_CMTP_DEBUG ==========
net/bluetooth/cmtp/capi.c:45:#ifndef CONFIG_BT_CMTP_DEBUG
net/bluetooth/cmtp/sock.c:46:#ifndef CONFIG_BT_CMTP_DEBUG
net/bluetooth/cmtp/core.c:46:#ifndef CONFIG_BT_CMTP_DEBUG
========== BT_HCI_CORE_DEBUG ==========
net/bluetooth/hci_core.c:50:#ifndef CONFIG_BT_HCI_CORE_DEBUG
net/bluetooth/hci_conn.c:48:#ifndef CONFIG_BT_HCI_CORE_DEBUG
net/bluetooth/hci_event.c:48:#ifndef CONFIG_BT_HCI_CORE_DEBUG
net/bluetooth/hci_sysfs.c:11:#ifndef CONFIG_BT_HCI_CORE_DEBUG
========== BT_HCI_SOCK_DEBUG ==========
net/bluetooth/hci_sock.c:51:#ifndef CONFIG_BT_HCI_SOCK_DEBUG
========== BT_HIDP_DEBUG ==========
net/bluetooth/hidp/sock.c:42:#ifndef CONFIG_BT_HIDP_DEBUG
net/bluetooth/hidp/core.c:49:#ifndef CONFIG_BT_HIDP_DEBUG
========== BT_L2CAP_DEBUG ==========
net/bluetooth/l2cap.c:53:#ifndef CONFIG_BT_L2CAP_DEBUG
========== BT_RFCOMM_DEBUG ==========
net/bluetooth/rfcomm/tty.c:44:#ifndef CONFIG_BT_RFCOMM_DEBUG
net/bluetooth/rfcomm/sock.c:55:#ifndef CONFIG_BT_RFCOMM_DEBUG
net/bluetooth/rfcomm/core.c:50:#ifndef CONFIG_BT_RFCOMM_DEBUG
========== BT_SCO_DEBUG ==========
net/bluetooth/sco.c:51:#ifndef CONFIG_BT_SCO_DEBUG
========== BT_SOCK_DEBUG ==========
net/bluetooth/af_bluetooth.c:46:#ifndef CONFIG_BT_SOCK_DEBUG
========== IP_FIB_TRIE_STATS ==========
net/ipv4/fib_trie.c:84:#undef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:138:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:160:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:571:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:612:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:878:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1313:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1318:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1347:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1370:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:1504:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:2155:#ifdef CONFIG_IP_FIB_TRIE_STATS
net/ipv4/fib_trie.c:2166:#endif /*  CONFIG_IP_FIB_TRIE_STATS */
========== IP_NF_NAT ==========
net/ipv4/netfilter/Kconfig:256:# If they want FTP, set to $CONFIG_IP_NF_NAT (m or y),
net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:157:#if !defined(CONFIG_IP_NF_NAT) && !defined(CONFIG_IP_NF_NAT_MODULE)
net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:157:#if !defined(CONFIG_IP_NF_NAT) && !defined(CONFIG_IP_NF_NAT_MODULE)
========== IP_NOSIOCRT ==========
net/ipv4/fib_frontend.c:253:#ifndef CONFIG_IP_NOSIOCRT
========== IP_PIMSM ==========
net/ipv4/ipmr.c:68:#define CONFIG_IP_PIMSM	1
net/ipv4/ipmr.c:174:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:265:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:399:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:455:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:549:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:559:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:946:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:992:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:1009:#ifdef CONFIG_IP_PIMSM
net/ipv4/ipmr.c:1154:#ifdef CONFIG_IP_PIMSM
========== IP_ROUTE_PERVASIVE ==========
net/ipv4/fib_semantics.c:525:#ifdef CONFIG_IP_ROUTE_PERVASIVE
========== IP_VS_DH_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_dh.c:58:#ifndef CONFIG_IP_VS_DH_TAB_BITS
net/ipv4/ipvs/ip_vs_dh.c:59:#define CONFIG_IP_VS_DH_TAB_BITS        8
net/ipv4/ipvs/ip_vs_dh.c:61:#define IP_VS_DH_TAB_BITS               CONFIG_IP_VS_DH_TAB_BITS
net/ipv4/ipvs/ip_vs_dh.c:61:#define IP_VS_DH_TAB_BITS               CONFIG_IP_VS_DH_TAB_BITS
net/ipv4/ipvs/ip_vs_dh.c:62:#define IP_VS_DH_TAB_SIZE               (1 << IP_VS_DH_TAB_BITS)
========== IP_VS_LBLCR_DEBUG ==========
net/ipv4/ipvs/ip_vs_lblcr.c:550:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
net/ipv4/ipvs/ip_vs_lblcr.c:652:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
net/ipv4/ipvs/ip_vs_lblcr.c:845:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
net/ipv4/ipvs/ip_vs_lblcr.c:854:#ifdef CONFIG_IP_VS_LBLCR_DEBUG
========== IP_VS_LBLCR_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_lblcr.c:77:#ifndef CONFIG_IP_VS_LBLCR_TAB_BITS
net/ipv4/ipvs/ip_vs_lblcr.c:78:#define CONFIG_IP_VS_LBLCR_TAB_BITS      10
net/ipv4/ipvs/ip_vs_lblcr.c:80:#define IP_VS_LBLCR_TAB_BITS     CONFIG_IP_VS_LBLCR_TAB_BITS
net/ipv4/ipvs/ip_vs_lblcr.c:80:#define IP_VS_LBLCR_TAB_BITS     CONFIG_IP_VS_LBLCR_TAB_BITS
net/ipv4/ipvs/ip_vs_lblcr.c:81:#define IP_VS_LBLCR_TAB_SIZE     (1 << IP_VS_LBLCR_TAB_BITS)
========== IP_VS_LBLC_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_lblc.c:77:#ifndef CONFIG_IP_VS_LBLC_TAB_BITS
net/ipv4/ipvs/ip_vs_lblc.c:78:#define CONFIG_IP_VS_LBLC_TAB_BITS      10
net/ipv4/ipvs/ip_vs_lblc.c:80:#define IP_VS_LBLC_TAB_BITS     CONFIG_IP_VS_LBLC_TAB_BITS
net/ipv4/ipvs/ip_vs_lblc.c:80:#define IP_VS_LBLC_TAB_BITS     CONFIG_IP_VS_LBLC_TAB_BITS
net/ipv4/ipvs/ip_vs_lblc.c:81:#define IP_VS_LBLC_TAB_SIZE     (1 << IP_VS_LBLC_TAB_BITS)
========== IP_VS_SH_TAB_BITS ==========
net/ipv4/ipvs/ip_vs_sh.c:55:#ifndef CONFIG_IP_VS_SH_TAB_BITS
net/ipv4/ipvs/ip_vs_sh.c:56:#define CONFIG_IP_VS_SH_TAB_BITS        8
net/ipv4/ipvs/ip_vs_sh.c:58:#define IP_VS_SH_TAB_BITS               CONFIG_IP_VS_SH_TAB_BITS
net/ipv4/ipvs/ip_vs_sh.c:58:#define IP_VS_SH_TAB_BITS               CONFIG_IP_VS_SH_TAB_BITS
net/ipv4/ipvs/ip_vs_sh.c:59:#define IP_VS_SH_TAB_SIZE               (1 << IP_VS_SH_TAB_BITS)
========== IRDA_DYNAMIC_WINDOW ==========
net/irda/irlap_frame.c:822:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_frame.c:832:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_frame.c:914:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_frame.c:917:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1011:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_event.c:1073:#else	/* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1077:#endif	/* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1119:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_event.c:1122:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1765:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap_event.c:1813:#else	/* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap_event.c:1817:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/qos.c:99:#ifndef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/qos.c:385:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/qos.c:409:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/qos.c:730:#ifndef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap.c:1026:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap.c:1035:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
net/irda/irlap.c:1158:#ifdef CONFIG_IRDA_DYNAMIC_WINDOW
net/irda/irlap.c:1162:#endif /* CONFIG_IRDA_DYNAMIC_WINDOW */
========== IRLAN_SEND_GRATUITOUS_ARP ==========
net/irda/irlan/irlan_common.c:62:#undef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
net/irda/irlan/irlan_common.c:398:#ifdef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
========== PACKET_MULTICAST ==========
net/packet/af_packet.c:100:#define CONFIG_PACKET_MULTICAST	1
net/packet/af_packet.c:162:#ifdef CONFIG_PACKET_MULTICAST
net/packet/af_packet.c:208:#ifdef CONFIG_PACKET_MULTICAST
net/packet/af_packet.c:854:#ifdef CONFIG_PACKET_MULTICAST
net/packet/af_packet.c:1224:#ifdef CONFIG_PACKET_MULTICAST
net/packet/af_packet.c:1365:#ifdef CONFIG_PACKET_MULTICAST
net/packet/af_packet.c:1509:#ifdef CONFIG_PACKET_MULTICAST
drivers/net/myri_sbus.c:383:			skb->pkt_type = PACKET_MULTICAST;
drivers/net/plip.c:558:			skb->pkt_type=PACKET_MULTICAST;
drivers/ieee1394/eth1394.c:773:			skb->pkt_type = PACKET_MULTICAST;
drivers/message/fusion/mptlan.c:1576:			skb->pkt_type = PACKET_MULTICAST;
drivers/media/dvb/dvb-core/dvb_net.c:185:			skb->pkt_type=PACKET_MULTICAST;
drivers/isdn/i4l/isdn_net.c:1378:			skb->pkt_type = PACKET_MULTICAST;
drivers/s390/net/qeth_main.c:2289:			skb->pkt_type = PACKET_MULTICAST;
drivers/s390/net/qeth_main.c:2315:	case PACKET_MULTICAST:
drivers/s390/net/qeth_main.c:2368:	case PACKET_MULTICAST:
drivers/s390/net/qeth_main.c:2442:		skb->pkt_type = PACKET_MULTICAST;
include/linux/netdevice.h:1048:			    skb->pkt_type != PACKET_MULTICAST)
include/linux/if_vlan.h:203:	case PACKET_MULTICAST:
include/linux/if_packet.h:28:#define PACKET_MULTICAST	2		/* To group		*/
net/ethernet/eth.c:168:			skb->pkt_type = PACKET_MULTICAST;
net/netfilter/xt_pkttype.c:38:			? PACKET_MULTICAST
net/8021q/vlan_dev.c:206:	case PACKET_MULTICAST:
net/ipv6/mcast.c:1296:	if (skb->pkt_type != PACKET_MULTICAST &&
net/atm/br2684.c:301:			skb->pkt_type = PACKET_MULTICAST;
net/ipv4/igmp.c:961:		if (skb->pkt_type == PACKET_MULTICAST ||
net/ipv4/netfilter/ipt_CLUSTERIP.c:367:	 * actually a unicast IP packet. TCP doesn't like PACKET_MULTICAST */
net/802/tr.c:212:			skb->pkt_type=PACKET_MULTICAST;
net/802/tr.c:216:		skb->pkt_type=PACKET_MULTICAST;
net/802/tr.c:225:	    (skb->pkt_type != PACKET_MULTICAST))
net/802/fddi.c:154:			skb->pkt_type = PACKET_MULTICAST;
========== SOCK_PACKET ==========
net/packet/af_packet.c:86:#define CONFIG_SOCK_PACKET	1
net/packet/af_packet.c:266:#ifdef CONFIG_SOCK_PACKET
net/packet/af_packet.c:939:#ifdef CONFIG_SOCK_PACKET
net/packet/af_packet.c:1016:#ifdef CONFIG_SOCK_PACKET
net/packet/af_packet.c:1030:#ifdef CONFIG_SOCK_PACKET
net/packet/af_packet.c:1049:#ifdef CONFIG_SOCK_PACKET
net/packet/af_packet.c:1172:#ifdef CONFIG_SOCK_PACKET
net/packet/af_packet.c:1859:#ifdef CONFIG_SOCK_PACKET
include/asm-mips/socket.h:89: * @SOCK_PACKET - linux specific way of getting packets at the dev level.
include/asm-mips/socket.h:99:	SOCK_PACKET	= 10,
include/asm-mips/socket.h:102:#define SOCK_MAX (SOCK_PACKET + 1)
include/linux/net.h:76: * @SOCK_PACKET: linux specific way of getting packets at the dev level.
include/linux/net.h:90:	SOCK_PACKET	= 10,
include/linux/net.h:93:#define SOCK_MAX (SOCK_PACKET + 1)
net/packet/af_packet.c:310:	 *	The SOCK_PACKET socket receives _all_ frames.
net/packet/af_packet.c:359:		return(-ENOTCONN);	/* SOCK_PACKET must be sent giving an address */
net/packet/af_packet.c:1003: *	Create a packet of type SOCK_PACKET.
net/packet/af_packet.c:1017:	    && sock->type != SOCK_PACKET
net/packet/af_packet.c:1031:	if (sock->type == SOCK_PACKET)
net/packet/af_packet.c:1050:	if (sock->type == SOCK_PACKET)
net/packet/af_packet.c:1119:	if (sock->type == SOCK_PACKET)
net/socket.c:1094:	if (family == PF_INET && type == SOCK_PACKET) {
net/socket.c:1098:			printk(KERN_INFO "%s uses obsolete (PF_INET,SOCK_PACKET)\n",
========== WANPIPE_MULTPPP ==========
net/wanrouter/wanmain.c:569:#ifdef CONFIG_WANPIPE_MULTPPP
net/wanrouter/wanmain.c:590:#ifdef CONFIG_WANPIPE_MULTPPP
net/wanrouter/wanmain.c:663:#ifdef CONFIG_WANPIPE_MULTPPP

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
