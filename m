From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [ANNOUNCE] iproute2 4.1.0
Date: Fri, 26 Jun 2015 14:49:11 -0700
Message-ID: <558DC8D7.4080803@cumulusnetworks.com>
References: <20150626130616.5a350099@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36412 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbbFZVtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 17:49:14 -0400
Received: by pdcu2 with SMTP id u2so81736728pdc.3
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 14:49:13 -0700 (PDT)
In-Reply-To: <20150626130616.5a350099@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I don't see the below fix in the 4.1 tarball you point below:
https://patchwork.ozlabs.org/patch/479743/

I am not sure yet if there was a problem with my submission. I intended=
=20
for it to go into 4.1.

Thanks,
Roopa

On 6/26/15, 1:06 PM, Stephen Hemminger wrote:
> Update to iproute2 for 4.1
>
> 4.1 is released and this is the corresponding iproute2.
> Noteable features:
>     * new command for controlling TIPC
>     * BPF support in tc
>     * Lots of RED cleanup work
>     * Enhancements to ss
>     * color option to ip command
>
> Source:
>    http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.1.0.=
tar.gz
>
> Repository:
>    git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.=
git
>
> Report problems (or enhancements) to the netdev@vger.kernel.org maili=
ng list.
>
> Sorry for the delay, Linus and I don't coordinate vacations.
>
> ---
> Andy Gospodarek (1):
>        iproute2: unify naming for entries offloaded to hardware
>
> Christophe Gouault (2):
>        xfrm: add command for configuring SPD hash table
>        xfrm: revise man page and document ip xfrm policy set
>
> Daniel Borkmann (9):
>        misc: header rebase, add bpf.h
>        tc: add eBPF support to f_bpf
>        tc, bpf: finalize eBPF support for cls and act front-end
>        tc: built-in eBPF exec proxy
>        examples: bpf: fix ld offs to have same prog loaded on ingress=
/egress
>        tc: {m, f}_ebpf: add option for dumping verifier log
>        tc: minor cleanup on ingress
>        tc: util: fix print_rate for ludicrous speeds
>        tc: bpf: add initial man page
>
> David Ward (9):
>        tc: red, gred: Rename overloaded variable wlog
>        tc: red, gred: Fix format specifier in burst size warning
>        tc: red, gred: Notify when using the default value for "bandwi=
dth"
>        tc: red: Mark "bandwidth" parameter as optional in usage text
>        tc: gred: Fix whitespace issues in code
>        tc: gred: Print usage text if no arguments appear after "gred"
>        tc: gred: Improve parameter/statistics output
>        tc: gred: Handle unsigned values properly in option parsing/pr=
inting
>        tc: gred: Adopt the term VQ in the command syntax and output
>
> Eric Dumazet (5):
>        ss: small optim in tcp_show_info()
>        ss: dctcp changes
>        ss: Fix allocation of cong control alg name
>        ss: speedup resolve_service()
>        ss: do not bindly dump two families
>
> Eric W. Biederman (8):
>        add a source addres length parameter to rt_addr_n2a
>        make the addr argument of ll_addr_n2a const
>        add support for printing AF_PACKET addresses
>        add address family to/from string helper functions.
>        misc whitespace cleanup
>        add support for the RTA_VIA attribute
>        add support for the RTA_NEWDST attribute.
>        add basic mpls support to iproute
>
> Felix Fietkau (1):
>        tc: add support for connmark action
>
> Jetchko Jekov (1):
>        gre: raising the size of the buffer holding nl messages.
>
> Lennert Buytenhek (1):
>        man ip-link: Add missing lowpan link type
>
> Lubomir Rintel (1):
>        ip: support RFC4191 router preference
>
> Maciej =C5=BBenczykowski (2):
>        iproute2: tc/m_pedit.c - remove dead code
>        iproute2: misc/ss.c - fix run_ssfilter af_packet when protocol=
 =3D=3D 0
>
> Madhu Challa (1):
>        ip: enable configuring multicast group autojoin
>
> Mathias Nyman (1):
>        ip: Add color output option
>
> Mazhar Rana (1):
>        mroute: "ip mroute show" not working when "to" and/or "from" i=
s given
>
> Mike Frysinger (1):
>        enable transparent LFS
>
> Nicolas Dichtel (5):
>        netns: allow to dump and monitor nsid
>        ipxfrm: wrong nl msg sent on deleteall cmd
>        tc: fix compilation warning on 32bits arch
>        libnamespaces: fix warning about syscall()
>        mroute: remove invalid check against NLM_F_MULTI
>
> Pavel =C5=A0imerda (5):
>        turn Makefile more distribution friendly
>        ip-xfrm: support 'proto any' with 'sport' and 'dport'
>        cbq: fix find syntax in example
>        lnstat: run indefinitely by default
>        lnstat: dump to stdout, not stderr
>
> Richard Alpe (1):
>        tipc: add new TIPC configuration tool
>
> Scott Feldman (1):
>        route: label externally offloaded routes
>
> Stephen Hemminger (16):
>        update headers files for net-next
>        update kernel headers to net-next 4.0-rc5
>        xfrm: fix build with later kernel headers
>        update kernel headers for net-next
>        fix whitespace
>        update kernel headers and add tc_connmark.h
>        update headers to reflect BPF changes
>        ip: document exit code
>        ip: return correct exit code on route failure
>        ip: fix exit code for rule failures
>        ip: fix exit code for addrlabel
>        Update to latest kernel headers
>        libnetlink: add size argument to rtnl_talk
>        update to 4.1-rc5 headers
>        change of rtnetlink to use RTN_F_OFFLOAD
>        v4.1.0
>
> Thadeu Lima de Souza Cascardo (1):
>        Fix changing tunnel remote and local address to any
>
> Thomas Graf (2):
>        iproute2: Fix typo in get_prefix_1()
>        route: Add missing newline in helptext
>
> Vadim Kochan (10):
>        tc util: Fix possible buffer overflow when print class id
>        ss: Fix wrong filter behaviour
>        man ip-link: Add deleting links by group
>        ip link: Add group in usage() for 'ip link delete'
>        man ip-link: Remove extra GROUP explanation
>        tests: Run each test in network namespace
>        tests: Add test for 'ip route add default'
>        ss: Show more info (ring,fanout) for packet socks
>        configure: Check for libmnl
>        tests: Add output testing
>
> Vlad Zolotarov (1):
>        ip link set vf: Added "query_rss" command
>
> WANG Cong (1):
>        tc: fill in handle before checking argc
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
