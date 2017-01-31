From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 5/5] bridge: vlan dst_metadata hooks in ingress
 and egress paths
Date: Tue, 31 Jan 2017 07:38:33 -0800
Message-ID: <5890AF79.4070801@cumulusnetworks.com>
References: <201701312023.j4hsk5qZ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        tgraf@suug.ch, hannes@stressinduktion.org, jbenc@redhat.com,
        pshelar@ovn.org, dsa@cumulusnetworks.com, hadi@mojatatu.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35014 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdAaPjW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:39:22 -0500
Received: by mail-pf0-f174.google.com with SMTP id f144so107505417pfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:38:35 -0800 (PST)
In-Reply-To: <201701312023.j4hsk5qZ%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/17, 4:52 AM, kbuild test robot wrote:
> Hi Roopa,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Roopa-Prabhu/bridge-per-vlan-dst_metadata-support/20170131-140750
> config: x86_64-allyesdebian (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
>
> All errors (new ones prefixed by >>):
>
>    net/built-in.o: In function `br_handle_frame':
>>> (.text+0x1bb3ca): undefined reference to `br_handle_ingress_vlan_tunnel'
>    net/built-in.o: In function `br_setport':
>    br_netlink.c:(.text+0x1be953): undefined reference to `nbp_vlan_tunnel_info_flush'
>    net/built-in.o: In function `br_vlan_tunnel_info':
>    br_netlink_tunnel.c:(.text+0x1bfc24): undefined reference to `nbp_vlan_tunnel_info_add'
>    br_netlink_tunnel.c:(.text+0x1bfc2f): undefined reference to `nbp_vlan_tunnel_info_delete'
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
Thanks and sorry abt these. will send v2 with fix for these and other reported warnings with CONFIG_BRIDGE VLAN_FILTERING off.
