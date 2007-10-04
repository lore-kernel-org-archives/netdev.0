From: "Avinash Ramanath" <avinashr@gmail.com>
Subject: Re: [BUGZILLA] network bugs
Date: Thu, 4 Oct 2007 09:55:43 -0700
Message-ID: <abcd72470710040955u73b114b5la75a80e4f03bdc8a@mail.gmail.com>
References: <20071004094426.5321af0e@freepuppy.rosehill>
	 <20071004094731.04b2cfcc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:50747 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757209AbXJDQzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 12:55:45 -0400
Received: by nf-out-0910.google.com with SMTP id g13so319838nfb
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2007 09:55:43 -0700 (PDT)
In-Reply-To: <20071004094731.04b2cfcc@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

Are there any bugs that I can look into?
I would like to get context of an area for a bug and then fix the issue.

Thanks,
Avinash.

On 10/4/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 68 bugs found.
> ID      Assignee        Status  Resolution      Version         Summary
> 2803    ambx1@neo.rr.com        ASSI            2.6.6   isa modem detected but does not initialize
> 3258    shemminger@osdl.org     ASSI            2.4.27 or 2.6.8.1       kernel IP autoconfig with PCMCIA
> 4206    laforge@gnumonks.org    ASSI            2.6.9   NAT/Masquerade not working
> 4595    kaber@trash.net         ASSI            2.6.11  Error inserting ebt_ulog
> 4809    kaber@trash.net         ASSI            2.6.12  AF_PACKET sockets ignore the SO_TIMESTAMP sockopt
> 4885    yoshfuji@linux-ipv6.org         ASSI            2.6.12.2        IPv6 Route entry being wrongly removed
> 5088    acme@ghostprotocols.net         NEW             2.6.x   disable ECN per connection
> 5091    laforge@gnumonks.org    NEW             2.6.10  connection tracking can give abnormal throughput result
> 5131    moin@blackhole.labs.rootshe...  ASSI            2.6.13-rc3-mm1  Computer hangs when default-gw becomes unreachable
> 5248    laforge@gnumonks.org    ASSI            2.4.33-pre1     Rapid loading and unloading of iptables modules gives oop...
> 5731    shemminger@osdl.org     REOP            2.6.14  Zero-length write() does not generate a datagram on conne...
> 5999    laforge@gnumonks.org    NEW             2.6.15.2        Iptables modules fail to load on Alpha arch
> 6036    other_other@kernel-bugs.osd...  NEW             2.6.14.3-grsec  mmap'ed write to socket hangs when connection remote end ...
> 6161    acme@ghostprotocols.net         NEW             2.6.14  Modem Slow down speed 50% after kernel upgrade
> 6171    acme@ghostprotocols.net         NEW             2.6.15  3c59x: netlink only updates online status each 60s
> 6187    acme@ghostprotocols.net         NEW             2.6.16-git      netlink: possible use after free in netlink_recvmsg
> 6197    kaber@trash.net         NEW             2.6.15 and all ...      unregister_netdevice: waiting for ppp9 to become free. Us...
> 6319    herbert@gondor.apana.org.au     ASSI            vanilla 2.6.16  ipsec tunnel asymmetrical mtu
> 6322    laforge@gnumonks.org    NEW             2.6.17.4        Kernel Panic (tc filter delete panic)
> 6339    kaber@trash.net         NEW             2.6.16  Wish: /proc or /sys-access to counters
> 6548    acme@ghostprotocols.net         NEW             2.6.16.16       MPPE Encrypt Decrypt module bug.
> 6681    shemminger@osdl.org     NEW             2.6.16-gentoo-r6        TC crash and rule freeze
> 6682    acme@ghostprotocols.net         NEW             2.6.15.6        BUG: soft lockup detected on CPU#0! / ksoftirqd takse 100...
> 6830    acme@ghostprotocols.net         NEW             2.6.9   Need a /proc to view IF-MIB counters not in /proc/net/dev
> 6917    acme@ghostprotocols.net         NEW             2.6.18-rc2-git6         BUG: warning at net/core/dev.c:1171/skb_checksum_help()
> 6966    laforge@gnumonks.org    NEW             2.6.17.6        ftp conntrack doesn't work
> 6998    yoshfuji@linux-ipv6.org         NEW             2.6.17  rp_filter missing for ipv6
> 7058    laforge@gnumonks.org    NEW             2.6.17.8        CONFIG_IP_ROUTE_FWMARK breaks rp_filter checks
> 7198    acme@ghostprotocols.net         NEW             2.6.18  balance-alb bonding oops when disconnecting primary slave...
> 7202    acme@ghostprotocols.net         NEW             2.6.17  sun happy meal ethernet driver problem
> 7512    samuel@sortiz.org       ASSI            2.6.19-rc5      irda: sock_error in af_irda.c:irda_recvmsg_stream
> 7554    marcel@holtmann.org     NEW             2.6.18  oops after insmod rfcomm and rmmod rfcomm
> 7709    acme@ghostprotocols.net         NEW             2.6.19.1        Exposing the string field lengths of the ethtool_drvinfo ...
> 7732    other_other@kernel-bugs.osd...  NEW             2.6.19.*        System freeze every 10 days
> 7846    acme@ghostprotocols.net         NEW             2.6.19.2        Strange trouble with samba and 2.6.19 kernel
> 7952    acme@ghostprotocols.net         NEW             2.6.18  slattach only works every other time
> 7974    acme@ghostprotocols.net         NEW             2.6.20  (bonding): scheduling while atomic
> 7983    yi.zhu@intel.com        NEW             2.6.19.2        kernel BUG at kernel/workqueue.c:150!
> 8054    acme@ghostprotocols.net         NEW             2.6.21-rc1      tipc_ref_discard tipc_deleteport locking dependency
> 8085    networking_netfilter-iptabl...  NEW             2.6.20  performance drop in 2.6.20 (CONFIG_NF_CONNTRACK_SUPPORT)
> 8203    acme@ghostprotocols.net         NEW             2.6.20.1        Race: a lock is expected before calling llc_conn_state_pr...
> 8215    shemminger@osdl.org     REOP            2.6.20.1        A lock is expected before calling zero_fw_chain, but it ...
> 8218    acme@ghostprotocols.net         NEW             2.6.20  8021q - Vlan - Tag lost/missing on base interface when sn...
> 8253    acme@ghostprotocols.net         NEW             2.6.20-rc3      BUG: unable to handle kernel paging request at virtual ad...
> 8325    networking_netfilter-iptabl...  NEW             2.6.19-1.2911.f...      -j REDIRECT --to-ports 1000-1009, always first choosen
> 8338    networking_netfilter-iptabl...  NEW             2.6.20.7        NAT of TCP connections broken
> 8382    yoshfuji@linux-ipv6.org         NEW             2.6.20.9        2.6.20 cannot route packets outside tunnel
> 8474    acme@ghostprotocols.net         NEW             2.6.20.11       regression failure, can't even ping modem
> 8525    romieu@fr.zoreil.com    ASSI            2.6.20  Realtek RTL8168B does not initialize when rebooting from ...
> 8536    acme@ghostprotocols.net         NEW             2.6.x   Kernel drops UDP packets silently when reading from certa...
> 8561    acme@ghostprotocols.net         NEW             vanilla kernel ...      list_add corruption. prev->next should be next (f7d28794)...
> 8654    acme@ghostprotocols.net         NEW             Linux version 2...      possible connect() bug
> 8726    acme@ghostprotocols.net         NEW             2.6.22  MSG_TRUNC not regarded in unix_dgram_recvmsg()
> 8732    romieu@fr.zoreil.com    ASSI            UBUNTU 7.04, PC...      Samba - very slow -one way- speed on AMD 690
> 8736    acme@ghostprotocols.net         NEW             2.6.22  New TC deadlock scenario
> 8754    yoshfuji@linux-ipv6.org         NEW             2.6.20, 2.6.22  Kernel addrconf modifies MTU of non-kernel routes
> 8755    yoshfuji@linux-ipv6.org         NEW             2.6.20, 2.6.22  "ip -6 route change " behaves like "ip -6 route add"
> 8766    acme@ghostprotocols.net         NEW             2.6.20  802.1q VLAN stacking + REORDER_HDR is broken
> 8891    acme@ghostprotocols.net         NEW             2.6.22.1        in-kernel rpc generates broken RPCBPROC_GETVERSADDR v4 re...
> 8895    yoshfuji@linux-ipv6.org         NEW             2.6.22.3 and al...      An ioctl to delete an ipv6 tunnel leads to a kernel panic
> 8914    shemminger@osdl.org     NEW             2.6.22.4        filter attached to prio qdisc breaks priomap handling of ...
> 8961    other_other@kernel-bugs.osd...  NEW             2.6.22.3        BUG triggered by oidentd in netlink code
> 8962    shemminger@osdl.org     REOP            2.6.23-rc4      sky2: network intermittently unavailable after ifdown/ifu...
> 8971    shemminger@osdl.org     NEW             2.6.18.* - 2.6....      htb class delete causes kernelpanic and other htb bugs.
> 8996    acme@ghostprotocols.net         NEW             2.6.22  atl1 driver cause kernel oops IF ram > 4Gyte and a lot of...
> 9077    rjwysocki@sisk.pl       ASSI            2.6.23-rc6      build #301 failed for 2.6.23-rc6-g0d4cbb5 in linux/driver...
> 9079    other_other@kernel-bugs.osd...  NEW             2.6.23-rc3      NETDEV WATCHDOG: eth0: transmit timed out
> 9080    rjwysocki@sisk.pl       ASSI            2.6.23-rc2      Weird network problems with 2.6.23-rc2
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
