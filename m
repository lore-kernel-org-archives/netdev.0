From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [BUG] Open networking bugs (73)
Date: Mon, 3 Dec 2007 17:52:48 -0800
Message-ID: <20071203175248.5fdc39d0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40768 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750730AbXLDBxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 20:53:39 -0500
Received: from freepuppy.rosehill (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id lB41raRQ002686
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 3 Dec 2007 17:53:38 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of these are old and maybe already fixed?

ID	Owner			Description
2803	ambx1@neo.rr.com 	isa modem detected but does not initialize 
4206	laforge@gnumonks.org 	NAT/Masquerade not working 
4595	kaber@trash.net 	Error inserting ebt_ulog 
4809	kaber@trash.net 	AF_PACKET sockets ignore the SO_TIMESTAMP sockopt 
4885	yoshfuji@linux-ipv6.org 	IPv6 Route entry being wrongly removed 
5088	acme@ghostprotocols.net 	disable ECN per connection 
5091	laforge@gnumonks.org 	connection tracking can give abnormal throughput result 
5131	moin@blackhole.labs.rootshe... 	Computer hangs when default-gw becomes unreachable 
5248	laforge@gnumonks.org 	Rapid loading and unloading of iptables modules gives oop... 
5999	laforge@gnumonks.org 	Iptables modules fail to load on Alpha arch 
6036	other_other@kernel-bugs.osd... 	mmap'ed write to socket hangs when connection remote end ... 
6161	acme@ghostprotocols.net 	Modem Slow down speed 50% after kernel upgrade 
6187	acme@ghostprotocols.net 	netlink: possible use after free in netlink_recvmsg 
6197	kaber@trash.net 	unregister_netdevice: waiting for ppp9 to become free. Us... 
6319	herbert@gondor.apana.org.au 	ipsec tunnel asymmetrical mtu 
6322	laforge@gnumonks.org 	Kernel Panic (tc filter delete panic) 
6339	kaber@trash.net 	Wish: /proc or /sys-access to counters 
6548	acme@ghostprotocols.net 	MPPE Encrypt Decrypt module bug. 
6681	shemminger@linux-foundation... 	TC crash and rule freeze 
6682	acme@ghostprotocols.net 	BUG: soft lockup detected on CPU#0! / ksoftirqd takse 100... 
6830	acme@ghostprotocols.net 	Need a /proc to view IF-MIB counters not in /proc/net/dev 
6917	acme@ghostprotocols.net 	BUG: warning at net/core/dev.c:1171/skb_checksum_help() 
6998	yoshfuji@linux-ipv6.org 	rp_filter missing for ipv6 
7058	laforge@gnumonks.org 	CONFIG_IP_ROUTE_FWMARK breaks rp_filter checks 
7198	acme@ghostprotocols.net 	balance-alb bonding oops when disconnecting primary slave... 
7202	acme@ghostprotocols.net 	sun happy meal ethernet driver problem 
7512	samuel@sortiz.org 	irda: sock_error in af_irda.c:irda_recvmsg_stream 
7554	marcel@holtmann.org 	oops after insmod rfcomm and rmmod rfcomm 
7709	acme@ghostprotocols.net 	Exposing the string field lengths of the ethtool_drvinfo ... 
7732	other_other@kernel-bugs.osd... 	System freeze every 10 days 
7846	acme@ghostprotocols.net 	Strange trouble with samba and 2.6.19 kernel 
7952	acme@ghostprotocols.net 	slattach only works every other time 
7974	acme@ghostprotocols.net 	(bonding): scheduling while atomic 
7983	yi.zhu@intel.com 	kernel BUG at kernel/workqueue.c:150! 
8054	acme@ghostprotocols.net 	tipc_ref_discard tipc_deleteport locking dependency 
8085	networking_netfilter-iptabl... 	performance drop in 2.6.20 (CONFIG_NF_CONNTRACK_SUPPORT) 
8107	acme@ghostprotocols.net 	dev->header_cache_update has a random value 
8203	acme@ghostprotocols.net 	Race: a lock is expected before calling llc_conn_state_pr... 
8215	shemminger@linux-foundation... 	A lock is expected before calling zero_fw_chain, but it ... 
8218	acme@ghostprotocols.net 	8021q - Vlan - Tag lost/missing on base interface when sn... 
8253	acme@ghostprotocols.net 	BUG: unable to handle kernel paging request at virtual ad... 
8325	networking_netfilter-iptabl... 	-j REDIRECT --to-ports 1000-1009, always first choosen 
8338	networking_netfilter-iptabl... 	NAT of TCP connections broken 
8382	yoshfuji@linux-ipv6.org 	2.6.20 cannot route packets outside tunnel 
8474	acme@ghostprotocols.net 	regression failure, can't even ping modem 
8536	acme@ghostprotocols.net 	Kernel drops UDP packets silently when reading from certa... 
8561	acme@ghostprotocols.net 	list_add corruption. prev->next should be next (f7d28794)... 
8654	acme@ghostprotocols.net 	possible connect() bug 
8659	yoshfuji@linux-ipv6.org 	Patch for bug #8635 breaks TCPv6 
8726	acme@ghostprotocols.net 	MSG_TRUNC not regarded in unix_dgram_recvmsg() 
8732	romieu@fr.zoreil.com 	Samba - very slow -one way- speed on AMD 690 
8736	acme@ghostprotocols.net 	New TC deadlock scenario 
8754	yoshfuji@linux-ipv6.org 	Kernel addrconf modifies MTU of non-kernel routes 
8755	yoshfuji@linux-ipv6.org 	"ip -6 route change " behaves like "ip -6 route add" 
8766	acme@ghostprotocols.net 	802.1q VLAN stacking + REORDER_HDR is broken 
8786	marcel@holtmann.org 	Dell 350 Bluetooth device (usb id 413c:8103) not found 
8891	acme@ghostprotocols.net 	in-kernel rpc generates broken RPCBPROC_GETVERSADDR v4 re... 
8895	yoshfuji@linux-ipv6.org 	An ioctl to delete an ipv6 tunnel leads to a kernel panic 
8961	other_other@kernel-bugs.osd... 	BUG triggered by oidentd in netlink code 
8971	shemminger@linux-foundation... 	htb class delete causes kernelpanic and other htb bugs. 
8975	shemminger@linux-foundation... 	Broadcasting fails when default gateway can't be reached. 
9079	romieu@fr.zoreil.com 	NETDEV WATCHDOG: eth0: transmit timed out 
9080	rjwysocki@sisk.pl 	Weird network problems with 2.6.23-rc2 
9124	acme@ghostprotocols.net 	Netconsole race crashed the system 
9128	acme@ghostprotocols.net 	PF_KEY SADB_GET messages return SADB_DUMP from the kernel 
9224	yoshfuji@linux-ipv6.org 	Settings to /proc/sys/net/ipv[46]/conf/all are not propag... 
9318	acme@ghostprotocols.net 	2.6.23.1-smp kernel panic (network-related) 
9342	shemminger@linux-foundation... 	a kernel error happend in the func: __skb_dequeue when us... 
9383	acme@ghostprotocols.net 	Appletalk packets are delivered to the last interface FD_SET 
9418	ming-baini@163.com 	Function tcp_v6_md5_do_del return value has error. 
9440	yoshfuji@linux-ipv6.org 	Problem in joinning a socket to ipv6 multicast address in... 
9449	acme@ghostprotocols.net 	"#define tc_index mark" into skbuff.h (useful option sugg... 
9471	acme@ghostprotocols.net 	[build bug] SCTP, net/sctp/auth.c, ./net/rxrpc/ar-key.c f... 
