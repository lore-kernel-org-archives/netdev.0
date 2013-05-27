From: Cong Wang <amwang@redhat.com>
Subject: Re: Some netfilter compile errors when CONFIG_IPV6=m
Date: Mon, 27 May 2013 18:56:57 +0800
Message-ID: <1369652217.8181.6.camel@cr0>
References: <1368499552.2507.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1368499552.2507.5.camel@cr0>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cc'ing Bj=C3=B8rn who cares IPV6=3Dm compile errors very much. :)

BTW, this is what I found while testing my vxlan patches with IPV6=3Dm.

On Tue, 2013-05-14 at 10:45 +0800, Cong Wang wrote:
> Hi, all
>=20
> I got the following compile errors when I compile IPv6 as a module an=
d
> most of the rest are built into core kernel. David Miller insists we
> should fix this kind of error and not by adding Kconfig tricks.
>=20
> net/built-in.o: In function `nf_tproxy_get_sock_v6':
> /home/wangcong/linux/include/net/netfilter/nf_tproxy_core.h:177:
> undefined reference to `udp6_lib_lookup'
> /home/wangcong/linux/include/net/netfilter/nf_tproxy_core.h:177:
> undefined reference to `udp6_lib_lookup'
> net/built-in.o: In function `tproxy_tg_init':
> /home/wangcong/linux/net/netfilter/xt_TPROXY.c:415: undefined referen=
ce
> to `nf_defrag_ipv6_enable'
> net/built-in.o: In function `socket_mt_init':
> /home/wangcong/linux/net/netfilter/xt_socket.c:366: undefined referen=
ce
> to `nf_defrag_ipv6_enable'
>=20
> My .config is:
>=20
> CONFIG_NET_IPGRE=3Dm
> CONFIG_IPV6=3Dm
> CONFIG_INET6_AH=3Dm
> CONFIG_INET6_ESP=3Dm
> CONFIG_INET6_IPCOMP=3Dm
> CONFIG_IPV6_MIP6=3Dm
> CONFIG_INET6_XFRM_TUNNEL=3Dm
> CONFIG_INET6_TUNNEL=3Dm
> CONFIG_INET6_XFRM_MODE_TRANSPORT=3Dm
> CONFIG_INET6_XFRM_MODE_TUNNEL=3Dm
> CONFIG_INET6_XFRM_MODE_BEET=3Dm
> CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=3Dm
> CONFIG_IPV6_SIT=3Dm
> CONFIG_IPV6_TUNNEL=3Dm
> CONFIG_IPV6_GRE=3Dm
> CONFIG_NF_CONNTRACK_H323=3Dm
> CONFIG_NETFILTER_XT_TARGET_TEE=3Dm
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dm
> CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=3Dm
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dm
> CONFIG_NF_NAT_H323=3Dm
> CONFIG_NF_DEFRAG_IPV6=3Dm
> CONFIG_NF_CONNTRACK_IPV6=3Dm
> CONFIG_IP6_NF_IPTABLES=3Dm
> CONFIG_IP6_NF_MATCH_AH=3Dm
> CONFIG_IP6_NF_MATCH_EUI64=3Dm
> CONFIG_IP6_NF_MATCH_FRAG=3Dm
> CONFIG_IP6_NF_MATCH_OPTS=3Dm
> CONFIG_IP6_NF_MATCH_HL=3Dm
> CONFIG_IP6_NF_MATCH_IPV6HEADER=3Dm
> CONFIG_IP6_NF_MATCH_MH=3Dm
> CONFIG_IP6_NF_MATCH_RT=3Dm
> CONFIG_IP6_NF_TARGET_HL=3Dm
> CONFIG_IP6_NF_FILTER=3Dm
> CONFIG_IP6_NF_TARGET_REJECT=3Dm
> CONFIG_IP6_NF_MANGLE=3Dm
> CONFIG_IP6_NF_RAW=3Dm
> CONFIG_IP6_NF_SECURITY=3Dm
> CONFIG_NF_NAT_IPV6=3Dm
> CONFIG_IP6_NF_TARGET_MASQUERADE=3Dm
> CONFIG_BRIDGE_NF_EBTABLES=3Dm
> CONFIG_BRIDGE_EBT_BROUTE=3Dm
> CONFIG_BRIDGE_EBT_T_FILTER=3Dm
> CONFIG_BRIDGE_EBT_T_NAT=3Dm
> CONFIG_BRIDGE_EBT_802_3=3Dm
> CONFIG_BRIDGE_EBT_AMONG=3Dm
> CONFIG_BRIDGE_EBT_ARP=3Dm
> CONFIG_BRIDGE_EBT_IP=3Dm
> CONFIG_BRIDGE_EBT_IP6=3Dm
> CONFIG_BRIDGE_EBT_LIMIT=3Dm
> CONFIG_BRIDGE_EBT_MARK=3Dm
> CONFIG_BRIDGE_EBT_PKTTYPE=3Dm
> CONFIG_BRIDGE_EBT_STP=3Dm
> CONFIG_BRIDGE_EBT_VLAN=3Dm
> CONFIG_BRIDGE_EBT_ARPREPLY=3Dm
> CONFIG_BRIDGE_EBT_DNAT=3Dm
> CONFIG_BRIDGE_EBT_MARK_T=3Dm
> CONFIG_BRIDGE_EBT_REDIRECT=3Dm
> CONFIG_BRIDGE_EBT_SNAT=3Dm
> CONFIG_BRIDGE_EBT_LOG=3Dm
> CONFIG_BRIDGE_EBT_ULOG=3Dm
> CONFIG_BRIDGE_EBT_NFLOG=3Dm
> CONFIG_IP_SCTP=3Dm
> CONFIG_BRIDGE=3Dm
> CONFIG_BONDING=3Dm
>=20
> all the rest are either =3Dy or =3Dn.
>=20
>=20
> Thanks.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
