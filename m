From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] Exporting IPv6 statistics via netlink.
Date: Thu, 19 Apr 2007 13:24:12 -0700 (PDT)
Message-ID: <20070419.132412.48397910.davem@davemloft.net>
References: <20070419084412.GD521@postel.suug.ch>
	<20070419.175855.130993987.yoshfuji@linux-ipv6.org>
	<20070419.210454.79003206.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1766512AbXDSUYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 16:24:09 -0400
In-Reply-To: <20070419.210454.79003206.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 19 Apr 2007 21:04:54 +0900 (JST)

> net-2.6.22-20070417-stats-20070419

I tried to pull this but I killed it before it tried to merge
because it looked very large:

remote: Generating pack...
remote: Done counting 5200 objects.
remote: Result has 4227 objects.

such a small set of changes should not need so many objects
:-)

I imagined you created your net-2.6.22 tree from a more
recent clone of Linus's tree, and therefore I'd end
up getting all of those changes too.

What I'll do is try to pull your work into another tree,
extract out just the ipv6 changes discussed here and
then apply them as patches to my net-2.6.22 tree.

Actually, a pull into net-2.6.22 didn't at all, see below :-(

I'm going to rebase my tree today, so please resubmit this work
after I sent a notification here that I have done so.

Thank you.

davem@sunset:~/src/GIT$ git clone -l -s net-2.6.22/.git ipv6-2.6.22
Initialized empty Git repository in /home/davem/src/GIT/ipv6-2.6.22/.git/
Checking files out...
 100% (21559/21559) done
davem@sunset:~/src/GIT$ cd ipv6-2.6.22
davem@sunset:~/src/GIT/ipv6-2.6.22$ git pull git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.22-20070417-stats-20070419
remote: Generating pack...
remote: Done counting 5200 objects.
remote: Result has 4227 objects.
remote: Deltifying 4227 objects.
remote: 
Indexing 4227 objects.
remote: Total 4227, written 4227 (delta 3889), reused 1 (delta 1)
 100% (4227/4227) done
Resolving 3889 deltas.
 100% (3889/3889) done
1377 objects were added to complete this thin pack.
 100% (22194/22194) done
Auto-merged Documentation/feature-removal-schedule.txt
Auto-merged Documentation/networking/ip-sysctl.txt
Auto-merged arch/ia64/hp/sim/simeth.c
Auto-merged arch/ia64/sn/kernel/xpnet.c
Auto-merged drivers/char/random.c
Auto-merged drivers/connector/connector.c
Auto-merged drivers/infiniband/ulp/ipoib/ipoib_cm.c
Auto-merged drivers/isdn/gigaset/usb-gigaset.c
Auto-merged drivers/isdn/hysdn/hycapi.c
CONFLICT (content): Merge conflict in drivers/isdn/hysdn/hycapi.c
Auto-merged drivers/isdn/pcbit/capi.c
CONFLICT (content): Merge conflict in drivers/isdn/pcbit/capi.c
Auto-merged drivers/net/3c523.c
CONFLICT (content): Merge conflict in drivers/net/3c523.c
Auto-merged drivers/net/8139too.c
Auto-merged drivers/net/appletalk/ltpc.c
Auto-merged drivers/net/atari_bionet.c
Auto-merged drivers/net/atari_pamsnet.c
Auto-merged drivers/net/atl1/atl1_main.c
Auto-merged drivers/net/b44.c
Auto-merged drivers/net/bnx2.c
Auto-merged drivers/net/bonding/bond_main.c
Auto-merged drivers/net/chelsio/sge.c
Auto-merged drivers/net/cxgb3/cxgb3_offload.c
Auto-merged drivers/net/cxgb3/sge.c
Auto-merged drivers/net/defxx.c
Auto-merged drivers/net/e1000/e1000_main.c
Auto-merged drivers/net/ehea/ehea_main.c
Auto-merged drivers/net/forcedeth.c
Auto-merged drivers/net/irda/ali-ircc.c
Auto-merged drivers/net/irda/au1k_ir.c
Auto-merged drivers/net/irda/donauboe.c
Auto-merged drivers/net/irda/mcs7780.c
Auto-merged drivers/net/irda/nsc-ircc.c
Auto-merged drivers/net/irda/pxaficp_ir.c
Auto-merged drivers/net/irda/stir4200.c
Auto-merged drivers/net/irda/via-ircc.c
Auto-merged drivers/net/irda/w83977af_ir.c
Auto-merged drivers/net/ixgb/ixgb_main.c
Auto-merged drivers/net/loopback.c
CONFLICT (content): Merge conflict in drivers/net/loopback.c
Auto-merged drivers/net/macb.c
Auto-merged drivers/net/mv643xx_eth.c
Auto-merged drivers/net/myri10ge/myri10ge.c
Auto-merged drivers/net/netxen/netxen_nic_init.c
Auto-merged drivers/net/ni52.c
CONFLICT (content): Merge conflict in drivers/net/ni52.c
Auto-merged drivers/net/qla3xxx.c
Auto-merged drivers/net/r8169.c
Auto-merged drivers/net/sc92031.c
Auto-merged drivers/net/sis190.c
Auto-merged drivers/net/sk98lin/skge.c
Auto-merged drivers/net/skfp/skfddi.c
Auto-merged drivers/net/skge.c
Auto-merged drivers/net/sky2.c
Auto-merged drivers/net/sun3lance.c
Auto-merged drivers/net/sungem.c
Auto-merged drivers/net/tg3.c
Auto-merged drivers/net/tokenring/3c359.c
CONFLICT (content): Merge conflict in drivers/net/tokenring/3c359.c
Auto-merged drivers/net/tokenring/olympic.c
CONFLICT (content): Merge conflict in drivers/net/tokenring/olympic.c
Auto-merged drivers/net/tokenring/smctr.c
Auto-merged drivers/net/tokenring/tms380tr.c
Auto-merged drivers/net/wan/pc300_drv.c
Auto-merged drivers/net/wan/pc300_tty.c
Auto-merged drivers/net/wan/z85230.c
Auto-merged drivers/net/wireless/prism54/islpci_eth.c
CONFLICT (content): Merge conflict in drivers/net/wireless/prism54/islpci_eth.c
Auto-merged drivers/s390/net/qeth_main.c
Auto-merged drivers/scsi/scsi_netlink.c
Auto-merged drivers/scsi/scsi_transport_iscsi.c
Auto-merged drivers/usb/atm/usbatm.c
CONFLICT (content): Merge conflict in drivers/usb/atm/usbatm.c
Auto-merged drivers/usb/net/asix.c
Auto-merged fs/compat_ioctl.c
Auto-merged fs/ecryptfs/netlink.c
Auto-merged include/linux/dccp.h
Auto-merged include/linux/fib_rules.h
CONFLICT (content): Merge conflict in include/linux/fib_rules.h
Auto-merged include/linux/if_pppox.h
Auto-merged include/linux/netlink.h
Auto-merged include/linux/skbuff.h
CONFLICT (content): Merge conflict in include/linux/skbuff.h
Auto-merged include/linux/sysctl.h
Auto-merged include/linux/tcp.h
Auto-merged include/net/ip.h
Auto-merged include/net/pkt_cls.h
Auto-merged include/net/pkt_sched.h
Auto-merged include/net/tcp.h
CONFLICT (content): Merge conflict in include/net/tcp.h
Auto-merged include/net/udp.h
Auto-merged kernel/audit.c
Auto-merged kernel/hrtimer.c
Auto-merged kernel/time.c
Auto-merged lib/div64.c
Auto-merged net/appletalk/ddp.c
Auto-merged net/atm/br2684.c
Auto-merged net/atm/lec.c
Auto-merged net/atm/mpc.c
Auto-merged net/ax25/ax25_in.c
Auto-merged net/bridge/br.c
Auto-merged net/bridge/br_device.c
Auto-merged net/bridge/br_fdb.c
CONFLICT (content): Merge conflict in net/bridge/br_fdb.c
Auto-merged net/bridge/br_netfilter.c
CONFLICT (content): Merge conflict in net/bridge/br_netfilter.c
Auto-merged net/bridge/br_netlink.c
Auto-merged net/bridge/br_private.h
Auto-merged net/bridge/netfilter/ebt_ulog.c
Auto-merged net/core/dev.c
CONFLICT (content): Merge conflict in net/core/dev.c
Auto-merged net/core/fib_rules.c
CONFLICT (content): Merge conflict in net/core/fib_rules.c
Auto-merged net/core/netpoll.c
Auto-merged net/core/rtnetlink.c
CONFLICT (content): Merge conflict in net/core/rtnetlink.c
Auto-merged net/core/skbuff.c
CONFLICT (content): Merge conflict in net/core/skbuff.c
Auto-merged net/core/wireless.c
CONFLICT (content): Merge conflict in net/core/wireless.c
Auto-merged net/dccp/ccids/ccid3.c
CONFLICT (content): Merge conflict in net/dccp/ccids/ccid3.c
Auto-merged net/dccp/options.c
Auto-merged net/decnet/dn_dev.c
Auto-merged net/decnet/dn_rules.c
CONFLICT (content): Merge conflict in net/decnet/dn_rules.c
Auto-merged net/decnet/netfilter/dn_rtmsg.c
Auto-merged net/ieee80211/ieee80211_rx.c
Auto-merged net/ipv4/af_inet.c
Auto-merged net/ipv4/devinet.c
Auto-merged net/ipv4/esp4.c
CONFLICT (content): Merge conflict in net/ipv4/esp4.c
Auto-merged net/ipv4/fib_frontend.c
Auto-merged net/ipv4/fib_rules.c
CONFLICT (content): Merge conflict in net/ipv4/fib_rules.c
Auto-merged net/ipv4/fib_trie.c
Auto-merged net/ipv4/inet_diag.c
Auto-merged net/ipv4/ipcomp.c
Auto-merged net/ipv4/ipmr.c
CONFLICT (content): Merge conflict in net/ipv4/ipmr.c
Auto-merged net/ipv4/ipvs/ip_vs_app.c
Auto-merged net/ipv4/ipvs/ip_vs_core.c
Auto-merged net/ipv4/netfilter/ip_queue.c
Auto-merged net/ipv4/netfilter/ipt_CLUSTERIP.c
Auto-merged net/ipv4/netfilter/ipt_LOG.c
Auto-merged net/ipv4/netfilter/ipt_ULOG.c
Auto-merged net/ipv4/netfilter/nf_nat_helper.c
Auto-merged net/ipv4/tcp_input.c
CONFLICT (content): Merge conflict in net/ipv4/tcp_input.c
Auto-merged net/ipv4/tcp_ipv4.c
Auto-merged net/ipv4/tcp_minisocks.c
Auto-merged net/ipv4/tcp_output.c
CONFLICT (content): Merge conflict in net/ipv4/tcp_output.c
Auto-merged net/ipv4/udp.c
CONFLICT (content): Merge conflict in net/ipv4/udp.c
Auto-merged net/ipv4/xfrm4_mode_beet.c
CONFLICT (content): Merge conflict in net/ipv4/xfrm4_mode_beet.c
Auto-merged net/ipv6/addrconf.c
Auto-merged net/ipv6/af_inet6.c
Auto-merged net/ipv6/esp6.c
CONFLICT (content): Merge conflict in net/ipv6/esp6.c
Auto-merged net/ipv6/fib6_rules.c
Auto-merged net/ipv6/ip6_input.c
Auto-merged net/ipv6/ipcomp6.c
Auto-merged net/ipv6/netfilter/ip6_queue.c
Auto-merged net/ipv6/netfilter/ip6t_LOG.c
Auto-merged net/ipv6/raw.c
CONFLICT (content): Merge conflict in net/ipv6/raw.c
Auto-merged net/ipv6/route.c
Auto-merged net/ipv6/tcp_ipv6.c
Auto-merged net/ipv6/udp.c
CONFLICT (content): Merge conflict in net/ipv6/udp.c
Auto-merged net/irda/irttp.c
Auto-merged net/irda/wrapper.c
Auto-merged net/netfilter/nfnetlink.c
Auto-merged net/netfilter/nfnetlink_log.c
Auto-merged net/netfilter/nfnetlink_queue.c
Auto-merged net/netlink/af_netlink.c
CONFLICT (content): Merge conflict in net/netlink/af_netlink.c
Auto-merged net/netlink/genetlink.c
Auto-merged net/netrom/nr_in.c
Auto-merged net/netrom/nr_out.c
Auto-merged net/rose/af_rose.c
Auto-merged net/sched/act_mirred.c
Auto-merged net/sched/cls_api.c
Auto-merged net/sched/cls_basic.c
Auto-merged net/sched/cls_route.c
Auto-merged net/sched/cls_tcindex.c
Auto-merged net/sched/sch_api.c
Auto-merged net/sched/sch_hfsc.c
Auto-merged net/sched/sch_htb.c
Auto-merged net/sched/sch_ingress.c
Auto-merged net/sctp/input.c
Auto-merged net/socket.c
Auto-merged net/sunrpc/svcsock.c
Auto-merged net/wanrouter/wanmain.c
Auto-merged net/x25/x25_in.c
Auto-merged net/x25/x25_out.c
Auto-merged net/xfrm/xfrm_state.c
Auto-merged net/xfrm/xfrm_user.c
Auto-merged security/selinux/netlink.c
Automatic merge failed; fix conflicts and then commit the result.
davem@sunset:~/src/GIT/ipv6-2.6.22$ 
