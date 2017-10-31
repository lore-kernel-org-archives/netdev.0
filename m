From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2 compile and linking errors on Fedora 19
Date: Tue, 31 Oct 2017 11:59:41 -0700
Message-ID: <1509476381.3828.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAM_iQpV07bZscuS5g6nZJ1Ko_RYVv7QyxVtga_Ky5EnbxXhCug@mail.gmail.com>
         <CAM_iQpWAvurJb3-AnUWSAGxOEQ_eKp7basJ0qYmhM8VPVg-iqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:45129 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932447AbdJaS7o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:59:44 -0400
Received: by mail-io0-f195.google.com with SMTP id i38so1071372iod.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:59:44 -0700 (PDT)
In-Reply-To: <CAM_iQpWAvurJb3-AnUWSAGxOEQ_eKp7basJ0qYmhM8VPVg-iqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 11:27 -0700, Cong Wang wrote:
> On Tue, Oct 31, 2017 at 10:58 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > Hi,
> >
> > The latest iproute2 in git fails with the following compile error on
> > Fedora 19 (I know it is very old!):
> 
> v4.11.0 compiles and links fine.

Same problem here, using Ubuntu trusty

root@edumazet-glaptop3:/usr/src/iproute2# make clean >/dev/null
root@edumazet-glaptop3:/usr/src/iproute2# make

lib
make[1]: Entering directory `/usr/src/iproute2/lib'
    CC       libgenl.o
    CC       ll_map.o
    CC       libnetlink.o
libnetlink.c:118:2: warning: #warning "libmnl required for error
support" [-Wcpp]
 #warning "libmnl required for error support"
  ^
    AR       libnetlink.a
    CC       utils.o
    CC       rt_names.o
    CC       ll_types.o
    CC       ll_proto.o
    CC       ll_addr.o
    CC       inet_proto.o
    CC       namespace.o
    CC       json_writer.o
    CC       json_print.o
    CC       names.o
    CC       color.o
    CC       bpf.o
    CC       exec.o
    CC       fs.o
    CC       dnet_ntop.o
    CC       dnet_pton.o
    CC       ipx_ntop.o
    CC       ipx_pton.o
    CC       mpls_ntop.o
    CC       mpls_pton.o
    AR       libutil.a
make[1]: Leaving directory `/usr/src/iproute2/lib'

ip
make[1]: Entering directory `/usr/src/iproute2/ip'
    CC       ip.o
    CC       ipaddress.o
    CC       ipaddrlabel.o
    CC       iproute.o
    CC       iprule.o
    CC       ipnetns.o
    CC       rtm_map.o
    CC       iptunnel.o
    CC       ip6tunnel.o
    CC       tunnel.o
    CC       ipneigh.o
    CC       ipntable.o
    CC       iplink.o
    CC       ipmaddr.o
    CC       ipmonitor.o
    CC       ipmroute.o
    CC       ipprefix.o
    CC       iptuntap.o
    CC       iptoken.o
    CC       ipxfrm.o
    CC       xfrm_state.o
    CC       xfrm_policy.o
    CC       xfrm_monitor.o
    CC       iplink_dummy.o
    CC       iplink_ifb.o
    CC       iplink_nlmon.o
    CC       iplink_team.o
    CC       iplink_vcan.o
    CC       iplink_vxcan.o
    CC       iplink_vlan.o
    CC       link_veth.o
    CC       link_gre.o
    CC       iplink_can.o
    CC       iplink_xdp.o
    CC       iplink_macvlan.o
    CC       ipl2tp.o
    CC       link_vti.o
    CC       link_vti6.o
    CC       iplink_vxlan.o
    CC       tcp_metrics.o
    CC       iplink_ipoib.o
    CC       ipnetconf.o
    CC       link_ip6tnl.o
    CC       link_iptnl.o
    CC       link_gre6.o
    CC       iplink_bond.o
    CC       iplink_bond_slave.o
    CC       iplink_hsr.o
    CC       iplink_bridge.o
    CC       iplink_bridge_slave.o
    CC       ipfou.o
    CC       iplink_ipvlan.o
    CC       iplink_geneve.o
    CC       iplink_vrf.o
    CC       iproute_lwtunnel.o
    CC       ipmacsec.o
    CC       ipila.o
    CC       ipvrf.o
    CC       iplink_xstats.o
    CC       ipseg6.o
    LINK     ip
xfrm_state.o: In function `xfrm_state_modify.constprop.3':
xfrm_state.c:(.text+0x2458): undefined reference to `strlcpy'
ipnetns.o: In function `netns_identify_pid':
ipnetns.c:(.text+0x12e0): undefined reference to `strlcpy'
ipxfrm.o: In function `xfrm_state_info_print':
ipxfrm.c:(.text+0x1c3b): undefined reference to `strlcat'
ipxfrm.c:(.text+0x1c4d): undefined reference to `strlcat'
ipxfrm.c:(.text+0x215f): undefined reference to `strlcat'
ipxfrm.o: In function `xfrm_policy_info_print':
ipxfrm.c:(.text+0x2299): undefined reference to `strlcat'
ipxfrm.c:(.text+0x22ab): undefined reference to `strlcat'
iproute_lwtunnel.o: In function `parse_encap_seg6':
iproute_lwtunnel.c:(.text+0xa8f): undefined reference to `strlcpy'
ipvrf.o: In function `vrf_switch':
ipvrf.c:(.text+0x87d): undefined reference to `strlcpy'
ipvrf.o: In function `vrf_identify.constprop.2':
ipvrf.c:(.text+0xe4d): undefined reference to `strlcpy'
../lib/libutil.a(bpf.o): In function `bpf_find_mntpt.constprop.10':
bpf.c:(.text+0x766): undefined reference to `strlcpy'
../lib/libutil.a(bpf.o): In function `bpf_get_work_dir':
bpf.c:(.text+0xb07): undefined reference to `strlcpy'
../lib/libutil.a(fs.o):fs.c:(.text+0x44f): more undefined references to
`strlcpy' follow
collect2: error: ld returned 1 exit status
make[1]: *** [ip] Error 1
make[1]: Leaving directory `/usr/src/iproute2/ip'
make: *** [all] Error 2
